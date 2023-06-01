# KLAZA CARIBOU RANGE
# 1) Convert linear and areal disturbance shapefiles to GPKG layers
#    and rename fields to be consistent with YG
# PV 2022-03-09

library(sf)
library(dplyr)

####################################################################################################
# FIX FIELD NAMES AND SAVE AS GPKG
####################################################################################################

bnd <- st_read('H:/Shared drives/DC Mapping/gisdata/Maegan_study_region/caribou_mapping_boundaries.shp') %>%
    st_transform(3579)
bnd$id <- c(1,2)
bnd <- filter(bnd, id==1) # Klaza range

# Lines
line <- st_read('digitizing/klaza/NT_Digitize_line_Feb152023.gpkg') %>%
    st_transform(3579)
linex <- rename(line, REF_ID=CODE, TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST,
        SCALE_CAPTURED=SCALE, IMAGE_RESOLUTION=RESOLUTION, IMAGE_SENSOR=SENSOR, 
        DISTURBANCE_YEAR=DIST_YEAR, CREATED_DATE=DIGZ_DATE)
linex <- mutate(linex, REF_ID=1:nrow(linex), DATABASE='Most Recent', DATA_SOURCE='Imagery', WIDTH_CLASS=NA,
    CREATED_BY='',CREATED_DATE='',FEATURE_VISIBILITY='',FLAG_YG='')
linex <- linex[,c('REF_ID','DATABASE','TYPE_INDUSTRY','TYPE_DISTURBANCE','WIDTH_M','WIDTH_CLASS','SCALE_CAPTURED',
    'DATA_SOURCE','IMAGE_NAME','IMAGE_DATE','IMAGE_RESOLUTION','IMAGE_SENSOR',
    'CREATED_BY','CREATED_DATE','FEATURE_VISIBILITY',
    'DISTURBANCE_YEAR','FLAG','FLAG_YG','VHR_ASSIST','NOTES')]

# Polygons
poly <- st_read('digitizing/klaza/NT_Digitize_polygon_Feb152023.gpkg') %>%
    st_transform(3579)
polyx <- rename(poly, REF_ID=CODE, TYPE_INDUSTRY=TYPE_IND, TYPE_DISTURBANCE=TYPE_DIST,
        SCALE_CAPTURED=SCALE, IMAGE_RESOLUTION=RESOLUTION, IMAGE_SENSOR=SENSOR, 
        DISTURBANCE_YEAR=DIST_YEAR, CREATED_DATE=DIGZ_DATE)
polyx <- mutate(polyx, REF_ID=1:nrow(polyx), DATABASE='Most Recent', DATA_SOURCE='Imagery',
    CREATED_BY='',CREATED_DATE='',FEATURE_VISIBILITY='',FLAG_YG='')
polyx <- polyx[,c('REF_ID','DATABASE','TYPE_INDUSTRY','TYPE_DISTURBANCE','SCALE_CAPTURED',
    'DATA_SOURCE','IMAGE_NAME','IMAGE_DATE','IMAGE_RESOLUTION','IMAGE_SENSOR',
    'CREATED_BY','CREATED_DATE','FEATURE_VISIBILITY',
    'DISTURBANCE_YEAR','FLAG','FLAG_YG','VHR_ASSIST','NOTES')]

# Save to gpkg file
st_write(bnd, 'digitizing/klaza/surface_disturbances.gpkg', 'Boundary', delete_layer=T)
st_write(linex, 'digitizing/klaza/surface_disturbances.gpkg', 'BP_Line', delete_layer=T)
st_write(polyx, 'digitizing/klaza/surface_disturbances.gpkg', 'BP_Poly', delete_layer=T)
