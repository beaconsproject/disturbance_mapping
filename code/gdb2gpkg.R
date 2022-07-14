library(sf)

yg_gdb <- "C:/Users/PIVER37/Documents/gisdata/YT/YG_SurfaceDisturbance/YG Surface Disturbance (May 2022).gdb"
layers <- st_layers(yg_gdb)

lyr <- st_read(yg_gdb, layers$name[1]) %>% st_transform(3578)
st_write(lyr, 'gisdata/yg_disturbances.gpkg', layers$name[1], delete_layer=T, delete_dsn=T)
for (i in 2:length(layers$name)) {
    cat(layers$name[i],'\n'); flush.console()
    lyr <- st_read(yg_gdb, layers$name[i]) %>% st_transform(3578)
    st_write(lyr, 'gisdata/yg_disturbances.gpkg', layers$name[i], delete_layer=T)
}
