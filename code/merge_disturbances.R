# Merge Beacons and YG disturbance maps and save to Github and Google drive
# PV 2022-10-06

library(sf)
library(dplyr)

# COPY METADATA

file.copy('C:/Users/PIVER37/Documents/github/dc-mapping/data/fda_10ab.txt',
    'G:/Shared drives/DC Mapping/gisdata/merged_disturbances/fda_10ab.txt')
file.copy('G:/Shared drives/DC Mapping/gisdata/merged_disturbances/fda_10ab.gpkg',
    'G:/Shared drives/DC Mapping/gisdata/merged_disturbances/fda_10ab (2022-10-06).gpkg')

## SELECT FDA AND DISTURBANCE DATA

fda_gpkg1 <- 'C:/Users/PIVER37/Documents/github/dc-mapping/data/fda_10ab.gpkg'
fda_gpkg2 <- 'G:/Shared drives/DC Mapping/gisdata/merged_disturbances/fda_10ab.gpkg'
shp_dir <- 'G:/Shared drives/DC Mapping/gisdata/merged_disturbances/fda_10ab_shp/'
fda <- st_read(fda_gpkg, 'fda')
bp_dir <- 'G:/Shared drives/DC Mapping/digitizing/SPOT_2020_21/FDA_10ab/'
#yg_poly <- 'G:/Shared drives/DC Mapping/digitizing/SPOT_2020_21/FDA_10ab/YG_SurfaceDisturbance_July2022_polygon_BEACONs_EDIT.shp'
#yg_line <- 'G:/Shared drives/DC Mapping/digitizing/SPOT_2020_21/FDA_10ab/YG_SurfaceDisturbance_July2022_line_BEACONs_EDIT.shp'
yg_gpkg <- 'G:/Shared drives/DC Mapping/digitizing/SPOT_2020_21/FDA_10ab/YG_SurfaceDisturbance_July2022_BEACONS_EDIT.gpkg'

## POLYGONAL DISTURBANCES

# Merge Marc, Maegan, and Hugues files
p_marc <- st_read(paste0(bp_dir, 'FDA10ab_digitize_polygons_MARC.shp'))
p_maegan <- st_read(paste0(bp_dir, 'FDA10ab_digitize_polygons_MAEGAN.shp')) %>% st_make_valid()
p_hugues <- st_read(paste0(bp_dir, 'FDA10ab_digitize_polygons_HUGUES.shp')) %>%
    mutate(CREATED_BY=ifelse(CREATED_BY=='Hugues', 'Hugues Bernasconi', CREATED_BY))
p_bp <- rbind(p_marc, p_hugues, p_maegan) %>%
    st_transform(3578) %>%
    st_intersection(fda) %>%
    select(TYPE_IND, TYPE_DIST, CREATED_BY, IMAGE_DATE) %>%
    rename(TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST)

table(p_bp$TYPE_INDUSTRY, p_bp$CREATED_BY)
table(p_bp$TYPE_DISTURBANCE, p_bp$CREATED_BY)


# Fix some values - these have now been fixed
#p_bp <- mutate(p_bp, 
#    TYPE_INDUSTRY=ifelse(TYPE_INDUSTRY=='Unkown', 'Unknown', TYPE_INDUSTRY),
#    TYPE_INDUSTRY=ifelse(TYPE_INDUSTRY=='forestry', 'Forestry', TYPE_INDUSTRY),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='Pullout', 'Pullout / Turn Area', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='Laydown Area', 'Laydown area', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='Dril Pad', 'Drill Pad', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='Cut and Fill', 'Road Cut and Fill', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='Uknown', 'Unknown', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='forestry', 'Forestry', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE %in% c('Quartz Mining - Signi','Quartz Mining - Signif','Quartz Mining - Significa'), 'Quartz Mining - Significant', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE %in% c('Gravel pit', 'Gravel Pit', 'Gravel Piyt / Quarry'), 'Gravel Pit / Quarry', TYPE_DISTURBANCE))

# Merge with YG
p_yg <- st_read(yg_gpkg, 'YG_SurfaceDisturbance_July2022_polygon_BEACONS_EDIT') %>% 
    st_transform(3578) %>%
    st_intersection(fda) %>%
    select(TYPE_INDUS, TYPE_DISTU, IMAGE_DATE) %>%
    rename(TYPE_INDUSTRY=TYPE_INDUS, TYPE_DISTURBANCE=TYPE_DISTU, geometry=geom) %>%
    mutate(CREATED_BY='Yukon Government')
p_bp_yg <- rbind(p_bp, p_yg)
p_bp_yg <- mutate(p_bp_yg, Area_ha=round(st_area(p_bp_yg)/10000,2))

table(p_bp_yg$TYPE_INDUSTRY, p_bp_yg$CREATED_BY)
table(p_bp_yg$TYPE_DISTURBANCE, p_bp_yg$CREATED_BY)

# Save to fda_gpkg
st_write(p_bp_yg, fda_gpkg1, 'Areal_Features+', delete_layer=T)
st_write(p_bp_yg, fda_gpkg2, 'Areal_Features+', delete_layer=T)

## LINEAR DISTURBANCES

# Merge Marc, Maegan, and Hugues files
l_marc <- st_read(paste0(bp_dir, 'FDA10ab_digitize_lines_MARC.shp'))
l_maegan <- st_read(paste0(bp_dir, 'FDA10ab_digitize_lines_MAEGAN.shp'))
l_hugues <- st_read(paste0(bp_dir, 'FDA10ab_digitize_lines_HUGUES.shp')) %>%
    mutate(CREATED_BY=ifelse(CREATED_BY=='Hugues', 'Hugues Bernasconi', CREATED_BY))
l_bp <- rbind(l_marc, l_hugues, l_maegan) %>%
    st_transform(3578) %>%
    st_intersection(fda) %>%
    select(TYPE_IND, TYPE_DIST, CREATED_BY, IMAGE_DATE) %>%
    rename(TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST)

table(l_bp$TYPE_INDUSTRY, l_bp$CREATED_BY)
table(l_bp$TYPE_DISTURBANCE, l_bp$CREATED_BY)

# Fix some values - these have now been fixed
# Note 1: TYPE_INDUSTRY=='Transportation' & TYPE_DISTURBANCE=='Unknown NRN' does not exist - is this an additional value that we want to define?
# Note 2: TYPE_INDUSTRY=='Mining' & TYPE_DISTURBANCE=='Mining' does not exist - should this be 'UNKNOWN'?
#l_bp <- mutate(l_bp, 
#    CREATED_BY=ifelse(CREATED_BY=='Maegan Elliott', 'Maegan', CREATED_BY), 
#    CREATED_BY=ifelse(CREATED_BY=='Marc Edwards', 'Marc', CREATED_BY), 
#    CREATED_BY=ifelse(CREATED_BY=='Hugues Bernasconi', 'Hugues', CREATED_BY), 
#    TYPE_INDUSTRY=ifelse(TYPE_INDUSTRY=='Unkown', 'Unknown', TYPE_INDUSTRY),
#    TYPE_INDUSTRY=ifelse(TYPE_INDUSTRY %in% c('Tranportation', 'Tranrportation', 'Transporation','Transportatioon'), 'Transportation', TYPE_INDUSTRY),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='unpaved Road', 'Unpaved Road', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE %in% c('Access road', 'Acccess Road'), 'Access Road', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_DISTURBANCE=='Survey / Cutline -s Quart', 'Survey / Cutline - Quartz', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_INDUSTRY %in% c('Mining','Unknown') & TYPE_DISTURBANCE %in% c('Cutline', 'Cut line', 'Survey  / Cutline'), 'Survey / Cutline', TYPE_DISTURBANCE),
#    TYPE_DISTURBANCE=ifelse(TYPE_INDUSTRY=='Unknown' & TYPE_DISTURBANCE=='Right of way', 'Right of Way', TYPE_DISTURBANCE))

# Merge with YG
l_yg <- st_read(yg_gpkg, 'YG_SurfaceDisturbance_July2022_line_BEACONS_EDIT') %>%
    st_transform(3578) %>%
    st_intersection(fda) %>%
    select(TYPE_INDUS, TYPE_DISTU, IMAGE_DATE) %>%
    rename(TYPE_INDUSTRY=TYPE_INDUS, TYPE_DISTURBANCE=TYPE_DISTU, geometry=geom) %>%
    mutate(CREATED_BY='Yukon Government')
l_bp_yg <- rbind(l_bp, l_yg)
l_bp_yg <- mutate(l_bp_yg, Length_km=round(st_length(l_bp_yg)/1000,2))

table(l_bp_yg$TYPE_INDUSTRY, l_bp_yg$CREATED_BY)
table(l_bp_yg$TYPE_DISTURBANCE, l_bp_yg$CREATED_BY)

# Save to fda_gpkg
st_write(l_bp_yg, fda_gpkg1, 'Linear_Features+', delete_layer=T)
st_write(l_bp_yg, fda_gpkg2, 'Linear_Features+', delete_layer=T)


# COPY SELECTED LAYERS TO SHAPEFILES

# Boundary
lyr <- st_read(fda_gpkg2, 'FDA')
st_write(lyr, shp_dir, 'fda.shp', driver='ESRI Shapefile', delete_layer=T)

# Linear disturbances
lyr <- st_read(fda_gpkg2, 'Linear_Features+') %>%
    dplyr::rename(INDUSTRY=TYPE_INDUSTRY, DISTURB=TYPE_DISTURBANCE, DATE=IMAGE_DATE, Len_km=Length_km)
st_write(lyr, shp_dir, 'linear_disturbances.shp', driver='ESRI Shapefile', delete_layer=T)

# Areal disturbances
lyr <- st_read(fda_gpkg2, 'Areal_Features+') %>%
    dplyr::rename(INDUSTRY=TYPE_INDUSTRY, DISTURB=TYPE_DISTURBANCE, DATE=IMAGE_DATE)
st_write(lyr, shp_dir, 'areal_disturbances.shp', driver='ESRI Shapefile', delete_layer=T)
