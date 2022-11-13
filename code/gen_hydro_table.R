library(sf)
library(dplyr)

fda='09ea'


streams <- st_read(paste0('data/fda_',fda,'_hydro.gpkg'), 'streams') %>% st_union()
lakes_rivers <- st_read(paste0('data/fda_',fda,'_hydro.gpkg'), 'lakes_rivers') %>% st_union()
linear <- st_read(paste0('data/fda_',fda,'.gpkg'), 'linear_features')
areal <- st_read(paste0('data/fda_',fda,'.gpkg'), 'areal_features')
bnd <- st_read(paste0('data/fda_',fda,'.gpkg'), 'fda')

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
readr::write_csv(x, paste0('data/fda_',fda,'_hydro.csv'))

plot(bnd$geom)
plot(hfp, col='blue', add=T)
plot(streams, add=T)
