library(sf)
library(dplyr)

streams <- st_read('gisdata/fda_10ab.gpkg', 'streams') %>% st_union()
lakes_rivers <- st_read('gisdata/fda_10ab.gpkg', 'lakes_rivers') %>% st_union()
linear <- st_read('gisdata/fda_10ab.gpkg', 'linear_features')
areal <- st_read('gisdata/fda_10ab.gpkg', 'areal_features')

x <- tibble(buffer=c(0,500,1000,1500,2000), streams=0, lakes_rivers=0)
for (i in c(0,500,1000,1500,2000)) {
    cat(i,'...\n'); flush.console()
    v1 <- st_union(st_buffer(linear, i))
    v2 <- st_union(st_buffer(areal, i))
    hfp <- st_union(v1, v2)
    streams_hfp <- st_intersection(streams, hfp)
    lakes_rivers_hfp <- st_intersection(lakes_rivers, hfp)
    x$streams[x$buffer==i] <- round(sum(st_length(streams_hfp))/sum(st_length(streams))*100,1)
    x$lakes_rivers[x$buffer==i] <- round(sum(st_area(lakes_rivers_hfp))/sum(st_area(lakes_rivers))*100,1)
}
x
write_csv(x, 'app/hydro.csv')
