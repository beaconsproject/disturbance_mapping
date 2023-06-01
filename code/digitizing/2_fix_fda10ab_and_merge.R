# FDA 10AB
# 1) Convert linear and areal disturbance shapefiles to GPKG layers
#    and rename fields to be consistent with YG
# 2) Merge BEACONs and YG disturbance datasets for FDA 10AB
# PV 2022-03-09

library(sf)
library(dplyr)

####################################################################################################
# FIX FIELD NAMES AND SAVE AS GPKG
####################################################################################################

input_dir <- 'H:/Shared drives/Disturbance Mapping/digitizing/SPOT_2020_21/FDA_10ab/'
fda <- st_read('data/fda_10ab.gpkg', 'fda')

# BEACONs polygonal disturbances (digitized by BEACONs)
poly1 <- st_read(paste0(input_dir,'FDA10ab_digitize_polygons_MAEGAN.shp')) %>% st_make_valid()
poly2 <- st_read(paste0(input_dir,'FDA10ab_digitize_polygons_HUGUES.shp'))
poly3 <- st_read(paste0(input_dir,'FDA10ab_digitize_polygons_MARC.shp'))
polyx <- rbind(poly1, poly2, poly3) %>%
    rename(REF_ID=CODE_POLY, TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST,
        SCALE_CAPTURED=SCALE, IMAGE_RESOLUTION=RESOLUTION, IMAGE_SENSOR=SENSOR, 
        DISTURBANCE_YEAR=DIST_YEAR, CREATED_DATE=DIGZ_DATE)
polyx <- mutate(polyx, REF_ID=1:nrow(polyx), DATABASE='Most Recent', DATA_SOURCE='Imagery',
    CREATED_BY='',CREATED_DATE='',FEATURE_VISIBILITY='',FLAG_YG='')
polyx <- polyx[,c('REF_ID','DATABASE','TYPE_INDUSTRY','TYPE_DISTURBANCE','SCALE_CAPTURED',
    'DATA_SOURCE','IMAGE_NAME','IMAGE_DATE','IMAGE_RESOLUTION','IMAGE_SENSOR',
    'CREATED_BY','CREATED_DATE','FEATURE_VISIBILITY',
    'DISTURBANCE_YEAR','FLAG','FLAG_YG','VHR_ASSIST','NOTES')]

# BEACONs linear disturbances (digitized by BEACONs)
line1 <- st_read(paste0(input_dir,'FDA10ab_digitize_lines_MAEGAN.shp'))
line2 <- st_read(paste0(input_dir,'FDA10ab_digitize_lines_HUGUES.shp'))
line3 <- st_read(paste0(input_dir,'FDA10ab_digitize_lines_MARC.shp'))
linex <- rbind(line1, line2, line3) %>%
    rename(REF_ID=CODE_LINE, TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST,
        SCALE_CAPTURED=SCALE, IMAGE_RESOLUTION=RESOLUTION, IMAGE_SENSOR=SENSOR, 
        DISTURBANCE_YEAR=DIST_YEAR, CREATED_DATE=DIGZ_DATE)
linex <- mutate(linex, REF_ID=1:nrow(linex), DATABASE='Most Recent', DATA_SOURCE='Imagery', WIDTH_CLASS=NA,
    CREATED_BY='',CREATED_DATE='',FEATURE_VISIBILITY='',FLAG_YG='')
linex <- linex[,c('REF_ID','DATABASE','TYPE_INDUSTRY','TYPE_DISTURBANCE','WIDTH_M','WIDTH_CLASS','SCALE_CAPTURED',
    'DATA_SOURCE','IMAGE_NAME','IMAGE_DATE','IMAGE_RESOLUTION','IMAGE_SENSOR',
    'CREATED_BY','CREATED_DATE','FEATURE_VISIBILITY',
    'DISTURBANCE_YEAR','FLAG','FLAG_YG','VHR_ASSIST','NOTES')]

# Replace SCALE from 10000 to 5000 (these were checked manually by PV in Feb 2023)

# Save to gpkg file
st_write(fda, 'digitizing/fda_10ab/surface_disturbances.gpkg', 'FDA', delete_layer=T)
st_write(linex, 'digitizing/fda_10ab/surface_disturbances.gpkg', 'BP_Line', delete_layer=T)
st_write(polyx, 'digitizing/fda_10ab/surface_disturbances.gpkg', 'BP_Poly', delete_layer=T)

####################################################################################################
# MERGE WITH YG DATA
####################################################################################################

bp_line <- st_read('digitizing/fda_10ab/surface_disturbances.gpkg', 'BP_Line') %>%
    st_transform(3579) %>%
    mutate(REF_ID=as.character(REF_ID), IMAGE_DATE=as.character(IMAGE_DATE), WIDTH_CLASS=as.character(WIDTH_CLASS),
        FLAG=as.character(FLAG))
bp_poly <- st_read('digitizing/fda_10ab/surface_disturbances.gpkg', 'BP_Poly') %>%
    st_transform(3579) %>%
    mutate(REF_ID=as.character(REF_ID), IMAGE_DATE=as.character(IMAGE_DATE), FLAG=as.character(FLAG))
yg_line <- st_read('digitizing/fda_10ab/YG_SurfaceDisturbance_July2022_BEACONS_EDIT.gpkg', 'YG_Line_edit') %>%
    rename(TYPE_INDUSTRY=TYPE_INDUS, TYPE_DISTURBANCE=TYPE_DISTU, WIDTH_CLASS=WIDTH_CLAS,
        SCALE_CAPTURED=SCALE_CAPT, DATA_SOURCE=DATA_SOURC, IMAGE_RESOLUTION=IMAGE_RESO, 
        IMAGE_SENSOR=IMAGE_SENS) %>%
    mutate(OBJECTID=NULL, Shape_Leng=NULL, CREATED_BY="", CREATED_DATE="", FEATURE_VISIBILITY="",
        DISTURBANCE_YEAR=as.integer(NA), FLAG="", FLAG_YG="", VHR_ASSIST="", NOTES="") %>%
    relocate(geom, .after=last_col())
yg_poly <- st_read('digitizing/fda_10ab/YG_SurfaceDisturbance_July2022_BEACONS_EDIT.gpkg', 'YG_Poly_edit') %>%
    rename(TYPE_INDUSTRY=TYPE_INDUS, TYPE_DISTURBANCE=TYPE_DISTU,
        SCALE_CAPTURED=SCALE_CAPT, DATA_SOURCE=DATA_SOURC, IMAGE_RESOLUTION=IMAGE_RESO, 
        IMAGE_SENSOR=IMAGE_SENS) %>%
    mutate(OBJECTID=NULL, Shape_Leng=NULL, Shape_Area=NULL, CREATED_BY="", CREATED_DATE="", FEATURE_VISIBILITY="", 
        DISTURBANCE_YEAR=as.integer(NA), FLAG="", FLAG_YG="", VHR_ASSIST="", NOTES="") %>%
    relocate(geom, .after=last_col())

# Merge BP and YG disturbance polygons
bpyg_poly <- bind_rows(bp_poly, yg_poly)
#p_bp_yg <- mutate(p_bp_yg, Area_ha=round(as.numeric(st_area(p_bp_yg))/10000,2))

# Merge BP and YG disturbance lines
bpyg_line <- bind_rows(bp_line, yg_line)
#l_bp_yg <- mutate(l_bp_yg, Length_km=round(as.numeric(st_length(l_bp_yg))/1000,2))

# Save to gpkg file
st_write(bpyg_poly, 'digitizing/fda_10ab/surface_disturbances.gpkg', 'SD_Poly', delete_layer=T)
st_write(bpyg_line, 'digitizing/fda_10ab/surface_disturbances.gpkg', 'SD_Line', delete_layer=T)
