library(sf)
library(dply)

# YT Surface Disturbance Data
gdb <- 'C:/Users/PIVER37/Documents/gisdata/123/yukon.gdb'
gpkg <- 'data/yt_disturbances.gpkg'
x <- st_read(gdb, 'SD_Line')
st_write(x, gpkg, 'SD_Line', delete_layer=T)
x <- st_read(gdb, 'SD_Poly') %>%
    st_cast('MULTIPOLYGON')
st_write(x, gpkg, 'SD_Poly', delete_layer=T)
x <- st_read(gdb, 'SD_MappingExtent') %>%
    st_cast('MULTIPOLYGON')
st_write(x, gpkg, 'SD_MappingExtent', delete_layer=T)
#st_layers(gdb)
#st_layers(gpkg)


# FDA Template Files
for (fda in c('10AA','10AB','10AC','10AD','10BA','10BB','10BC','10BD','10BE')) {
    gdb <- paste0('data/digitizing/template_',fda,'.gdb')
    gpkg <- paste0('data/digitizing/template_',fda,'.gpkg')
    x <- st_read(gdb, 'FDA', quiet=T)
    st_write(x, gpkg, 'FDA', delete_layer=T)
    x <- st_read(gdb, 'Grid_1k', quiet=T)
    st_write(x, gpkg, 'Grid_1k', delete_layer=T)
    if ('SD_MappingExtent' %in% st_layers(gdb)$name) {
        x <- st_read(gdb, 'SD_Line', quiet=T)
        st_write(x, gpkg, 'SD_Line', delete_layer=T)
        x <- st_read(gdb, 'SD_Poly', quiet=T) %>%
            st_cast('MULTIPOLYGON')
        st_write(x, gpkg, 'SD_Poly', delete_layer=T)
        x <- st_read(gdb, 'SD_MappingExtent', quiet=T) %>%
            st_cast('MULTIPOLYGON')
        st_write(x, gpkg, 'SD_MappingExtent', delete_layer=T)
    }
}
