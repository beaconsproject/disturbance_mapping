# Merge BEACONs and YG disturbance datasets
# To do: add code to run and save attribute validate to text file if validate=1
# PV 2022-11-29

library(sf)
library(dplyr)

################################################################################
# USER DEFINED SETTINGS
################################################################################

# FDA id and geopackage
fda_id <- '10ab'
fda_gpkg <- 'data/fda_10ab.gpkg'
fda <- st_read('data/fda_10ab.gpkg', 'fda')

# Validate attribute names?
validate <- 0 # if 1, tables will be saved to "data/validation/" folder

# Digitizing directory
input_dir <- 'H:/Shared drives/Disturbance Mapping/digitizing/SPOT_2020_21/FDA_10ab/'

# YG polygonal disturbances (edited by BEACONs) [note: why are names truncated?]
poly0 <- st_read(paste0(input_dir, 'YG_SurfaceDisturbance_July2022_BEACONS_EDIT.gpkg'), 
    'YG_SurfaceDisturbance_July2022_polygon_BEACONS_EDIT')

# YG linear disturbances (edited by BEACONs) [note: why are names truncated?]
line0 <- st_read(paste0(input_dir, 'YG_SurfaceDisturbance_July2022_BEACONS_EDIT.gpkg'), 
    'YG_SurfaceDisturbance_July2022_line_BEACONS_EDIT')

# BEACONs polygonal disturbances (digitized by BEACONs)
poly1 <- st_read(paste0(input_dir,'FDA',fda_id,'_digitize_polygons_MARC.shp'))
poly2 <- st_read(paste0(input_dir,'FDA',fda_id,'_digitize_polygons_MAEGAN.shp')) %>% st_make_valid()
poly3 <- st_read(paste0(input_dir,'FDA',fda_id,'_digitize_polygons_HUGUES.shp'))
polyx <- rbind(poly1, poly2, poly3)

# BEACONs linear disturbances (digitized by BEACONs)
line1 <- st_read(paste0(input_dir,'FDA',fda_id,'_digitize_lines_MARC.shp'))
line2 <- st_read(paste0(input_dir,'FDA',fda_id,'_digitize_lines_MAEGAN.shp'))
line3 <- st_read(paste0(input_dir,'FDA',fda_id,'_digitize_lines_HUGUES.shp'))
linex <- rbind(line1, line2, line3)

################################################################################
# MERGE POLYGONAL DISTURBANCES
################################################################################

# Merge BEACONs polygonal disturbances
p_bp <- polyx %>%
    st_transform(3578) %>%
    st_intersection(fda) %>%
    arrange(DIGZ_DATE) %>%
    mutate(CODE_POLY = paste0("bp", 1:nrow(.))) %>% # Add unique id in order of digitization date
    mutate(IMAGE_NAME = case_when(
        IMAGE_NAME == "SPOT" ~ "SPOT 2021", # Set all image names to be consistent
        IMAGE_NAME == "ESRI" ~ "ESRI basemap",
        TRUE ~ IMAGE_NAME)) %>% 
    select(CODE_POLY, 
           TYPE_IND, 
           TYPE_DIST, 
           DIST_YEAR,
           SCALE,
           CREATED_BY, 
           DIGZ_DATE,
           IMAGE_NAME,
           IMAGE_DATE,
           RESOLUTION,
           SENSOR,
           FLAG,
           VHR_ASSIST,
           NOTES) %>%
    rename(TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST)

# Uncomment to validate attribute spelling
#table(p_bp$TYPE_INDUSTRY, p_bp$CREATED_BY)
#table(p_bp$TYPE_DISTURBANCE, p_bp$CREATED_BY)

# Transform and clip YG polygonal disturbances
p_yg <- st_transform(poly0, 3578) %>%
    st_intersection(fda) %>%
    select(REF_ID,
           TYPE_INDUS, 
           TYPE_DISTU,
           SCALE_CAPT,
           IMAGE_NAME,
           IMAGE_DATE,
           IMAGE_RESO,
           IMAGE_SENS) %>%
    rename(CODE_POLY=REF_ID, TYPE_INDUSTRY=TYPE_INDUS, TYPE_DISTURBANCE=TYPE_DISTU, RESOLUTION=IMAGE_RESO, SENSOR=IMAGE_SENS, geometry=geom, SCALE=SCALE_CAPT) %>%
    mutate(CREATED_BY='Yukon Government', DIGZ_DATE=NA, FLAG=NA, VHR_ASSIST=NA, NOTES=NA, DIST_YEAR=NA,
           IMAGE_DATE = as.Date(IMAGE_DATE))

# Merge BEACONs and YG disturbance polygons
p_bp_yg <- rbind(p_bp, p_yg)
p_bp_yg <- mutate(p_bp_yg, Area_ha=round(as.numeric(st_area(p_bp_yg))/10000,2))

# Uncomment to validate attribute spelling
#table(p_bp_yg$TYPE_INDUSTRY, p_bp_yg$CREATED_BY)
#table(p_bp_yg$TYPE_DISTURBANCE, p_bp_yg$CREATED_BY)

# Save to fda_gpkg
st_write(p_bp_yg, fda_gpkg, 'Areal_Features+', delete_layer=T)

################################################################################
# MERGE LINEAR DISTURBANCES
################################################################################

# Merge BEACONs linear disturbances
l_bp <- linex %>%
    st_transform(3578) %>%
    st_intersection(fda) %>%
    arrange(DIGZ_DATE) %>%
    mutate(CODE_LINE = paste0("bp", 1:nrow(.))) %>% # Add unique id in order of digitization date
    mutate(IMAGE_NAME = case_when(IMAGE_NAME == "SPOT" ~ "SPOT 2021", # Set all image names to be consistent
                                  IMAGE_NAME == "ESRI" ~ "ESRI basemap",
                                  TRUE ~ IMAGE_NAME)) %>% 
    select(CODE_LINE,
           TYPE_IND, 
           TYPE_DIST, 
           DIST_YEAR,
           WIDTH_M,
           SCALE,
           CREATED_BY, 
           DIGZ_DATE,
           IMAGE_NAME,
           IMAGE_DATE,
           RESOLUTION,
           SENSOR,
           FLAG,
           VHR_ASSIST,
           NOTES) %>%
    rename(TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST)

# Uncomment to validate attribute spelling
#table(l_bp$TYPE_INDUSTRY, l_bp$CREATED_BY)
#table(l_bp$TYPE_DISTURBANCE, l_bp$CREATED_BY)

# Transform and clip YG linear disturbances
l_yg <- st_transform(line0, 3578) %>%
    st_intersection(fda) %>%
    select(REF_ID,
           TYPE_INDUS, 
           TYPE_DISTU,
           WIDTH_M,
           SCALE_CAPT,
           IMAGE_NAME,
           IMAGE_DATE,
           IMAGE_RESO,
           IMAGE_SENS) %>%
    rename(CODE_LINE=REF_ID, TYPE_INDUSTRY=TYPE_INDUS, TYPE_DISTURBANCE=TYPE_DISTU, RESOLUTION=IMAGE_RESO, SENSOR=IMAGE_SENS, geometry=geom, SCALE=SCALE_CAPT) %>%
    mutate(CREATED_BY='Yukon Government', DIGZ_DATE=NA, FLAG=NA, VHR_ASSIST=NA, NOTES=NA, DIST_YEAR=NA,
           IMAGE_DATE = as.Date(IMAGE_DATE))

# Merge BEACONs and YG disturbance lines
l_bp_yg <- rbind(l_bp, l_yg)
l_bp_yg <- mutate(l_bp_yg, Length_km=round(as.numeric(st_length(l_bp_yg))/1000,2))

# Uncomment to validate attribute spelling
#table(l_bp_yg$TYPE_INDUSTRY, l_bp_yg$CREATED_BY)
#table(l_bp_yg$TYPE_DISTURBANCE, l_bp_yg$CREATED_BY)

# Save to fda_gpkg
st_write(l_bp_yg, fda_gpkg, 'Linear_Features+', delete_layer=T)
