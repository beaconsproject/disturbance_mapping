# Merge BEACONs and YG disturbance datasets for all of the Yukon
# PV 2023-03-09

library(sf)
library(dplyr)

bp_data <- 'digitizing/fda_10ab/surface_disturbances.gpkg'
yg_data <- 'C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb'
yt_gpkg <- 'C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gpkg'

yg_line <- st_read(yg_data, 'SD_Line') %>%
    mutate(Shape_Length=NULL, IMAGE_DATE=as.character(IMAGE_DATE)) %>%
    rename(geom=Shape)
yg_poly <- st_read(yg_data, 'SD_Poly') %>%
    mutate(Shape_Length=NULL, Shape_Area=NULL, IMAGE_DATE=as.character(IMAGE_DATE)) %>%
    rename(geom=Shape) %>%
    st_cast('MULTIPOLYGON')

bnd <- st_read(bp_data, 'FDA') %>% st_transform(3579)
bp_line <- st_read(bp_data, 'SD_Line') %>%
    mutate(SCALE_CAPTURED=as.integer(SCALE_CAPTURED), IMAGE_RESOLUTION=as.integer(IMAGE_RESOLUTION)) %>%
    select(names(yg_line))
bp_poly <- st_read(bp_data, 'SD_Poly') %>%
    mutate(SCALE_CAPTURED=as.integer(SCALE_CAPTURED), IMAGE_RESOLUTION=as.integer(IMAGE_RESOLUTION)) %>%
    select(names(yg_poly))


x_line <- st_difference(yg_line, bnd) %>%
    select(names(yg_line))
sd_line <- bind_rows(x_line, bp_line)


x_poly <- st_difference(yg_poly, bnd) %>%
    select(names(yg_poly))    
sd_poly <- bind_rows(x_poly, bp_poly)

st_write(sd_line, yt_gpkg, 'SD_Line_BP', delete_layer=T)
st_write(sd_poly, yt_gpkg, 'SD_Poly_BP', delete_layer=T)
