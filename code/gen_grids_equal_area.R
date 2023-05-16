# https://stackoverflow.com/questions/64569984/how-to-generate-10x10km-grid-cells-of-all-countries

library(sf)
library(stars)

for (fda in c('10AA','10AB','10AC','10AD','10BA','10BB','10BC','10BD','10BE')) {
    x <- st_read(paste0('data/digitizing/template_',fda,'.gdb'), 'FDA')
    grid = st_as_stars(st_bbox(x), dx = 1000, dy = 1000)
    grid = st_as_sf(grid) %>% st_cast('MULTIPOLYGON')
    grid = grid[x, ]
    st_write(grid, paste0('data/tmp/fda_',fda,'_grid_1k.shp'),delete_layer=T)
}
