library(sf)
library(dplyr)

fda <- st_read('gisdata/fda_10ab.gpkg', 'fda')
linear <- st_read('gisdata/fda_10ab.gpkg', 'linear_features')
areal <- st_read('gisdata/fda_10ab.gpkg', 'areal_features')

for (b1 in c(500,1000,1500,2000)) {
    for (b2 in c(500,1000,1500,2000)) {
        cat(b1,'and',b2,'...\n'); flush.console()
        v1 <- st_union(st_buffer(linear, b1))
        v2 <- st_union(st_buffer(areal, b2))
        hfp <- st_union(v1, v2)
        fda_hfp <- st_intersection(hfp, fda)
        st_write(fda_hfp, 'disturbanceViewer/data/fda_10ab_buffers.gpkg', paste0('linear',b1,'_areal',b2), delete_layer=T)
    }
}
