# Convert gdb files to gpkg files
# PV 2022-08-13

library(sf)

####################################################################################################
# YG surface disturbances
yg_in <- 'C:/Users/PIVER37/Documents/gisdata/YT/YG_SurfaceDisturbance/YG_SurfaceDisturbance_July2022.gdb'
yg_out <- 'C:/Users/PIVER37/Documents/github/dc-mapping/data/yg_disturbances.gpkg'
layers <- st_layers(yg_in)

lyr <- st_read(yg_in, 'SD_Point') %>% st_transform(3578)
st_write(lyr, yg_out, 'SD_Point', delete_layer=T, delete_dsn=T)
lyr <- st_read(yg_in, 'SD_Line') %>% st_transform(3578)
st_write(lyr, yg_out, 'SD_Line', delete_layer=T)
lyr <- st_read(yg_in, 'SD_MappingExtent') %>% st_transform(3578) %>% st_cast('MULTIPOLYGON')
st_write(lyr, yg_out, 'SD_MappingExtent', delete_layer=T)
lyr <- st_read(yg_in, 'SD_Polygon') %>% st_transform(3578)
st_write(lyr, yg_out, 'SD_Polygon', delete_layer=T)
st_layers(yg_in)
st_layers(yg_out)


####################################################################################################
# Canada
ca_gdb <- 'C:/Users/PIVER37/Documents/gisdata/123/canada.gdb'
ca_gpkg <- 'C:/Users/PIVER37/Documents/gisdata/123/canada.gpkg'
layers <- st_layers(ca_gdb)

lyr <- st_read(ca_gdb, layers$name[1])
st_write(lyr, ca_gpkg, layers$name[1], delete_layer=T, delete_dsn=T)
for (i in 2:length(layers$name)) {
    cat(layers$name[i],'\n'); flush.console()
    lyr <- st_read(ca_gdb, layers$name[i])
    st_write(lyr, ca_gpkg, layers$name[i], delete_layer=T)
}

####################################################################################################
# KDTT
gdb <- 'C:/Users/PIVER37/Documents/gisdata/123/kdtt.gdb'
gpkg <- 'C:/Users/PIVER37/Documents/github/dc-mapping/data/kdtt.gpkg'
layers <- st_layers(gdb)

# Boundary
lyr <- st_read(gdb, 'bnd')
st_write(lyr, gpkg, 'kdtt', delete_layer=T, delete_dsn=T)

# Y2Y Region Boundary
lyr <- st_read(ca_gdb, 'Y2Y_region')
st_write(lyr, gpkg, 'y2y', delete_layer=T)

# NTS
lyr <- st_read(gdb, 'nts_50k_level12')
st_write(lyr, gpkg, 'nts', delete_layer=T)

# HydroBasins level 12
lyr <- st_read(gdb, 'level12')
st_write(lyr, gpkg, 'level12', delete_layer=T)

# FDA9
lyr <- st_read(gdb, 'fda9')
st_write(lyr, gpkg, 'fda', delete_layer=T)

# NHN18
lyr <- st_read(gdb, 'nhn18')
st_write(lyr, gpkg, 'nhn', delete_layer=T)

# FDA9_NTS
lyr <- st_read(gdb, 'fda9_nts')
st_write(lyr, gpkg, 'nhn_nts', delete_layer=T)

####################################################################################################
# FDA10AB disturbance map
gpkg <- 'G:/Shared drives/DC Mapping/gisdata/YT_disturbances/data/fda_10ab.gpkg'
shp_dir <- 'G:/Shared drives/DC Mapping/gisdata/YT_disturbances/shapefiles/'
layers <- st_layers(gpkg)

# Boundary
lyr <- st_read(gpkg, 'FDA')
st_write(lyr, shp_dir, 'fda.shp', driver='ESRI Shapefile', delete_layer=T)

# Linear disturbances
lyr <- st_read(gpkg, 'Linear_Features+') %>%
    dplyr::rename(INDUSTRY=TYPE_INDUSTRY, DISTURB=TYPE_DISTURBANCE, DATE=IMAGE_DATE, Len_km=Length_km)
st_write(lyr, shp_dir, 'linear_disturbances.shp', driver='ESRI Shapefile', delete_layer=T)

# Areal disturbances
lyr <- st_read(gpkg, 'Areal_Features+') %>%
    dplyr::rename(INDUSTRY=TYPE_INDUSTRY, DISTURB=TYPE_DISTURBANCE, DATE=IMAGE_DATE)
st_write(lyr, shp_dir, 'areal_disturbances.shp', driver='ESRI Shapefile', delete_layer=T)
