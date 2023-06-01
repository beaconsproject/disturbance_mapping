# https://stackoverflow.com/questions/64569984/how-to-generate-10x10km-grid-cells-of-all-countries

library(sf)
library(dplyr)
library(stars)

# Create Yukon-wide 100-km2 grid
x <- st_read('../../../gisdata/123/boreal_cordillera_plus.gdb', 'bnd_buf50k') %>%
    st_transform(3579)
#x <- st_read('../../../gisdata/123/yt_disturbance_mapping.gdb', 'Yukon_Planning_Regions_250k')
grid = st_as_stars(st_bbox(x), dx = 10000, dy = 10000)
grid = st_as_sf(grid) %>% st_cast('MULTIPOLYGON')
grid = grid[x, ]
grid100 = mutate(grid, id=1:nrow(grid)) %>%
    rename(status=values)
st_write(grid100, 'digitizing/grid_100k.gpkg', delete_layer=T)


# Planet priority grids
#x <- st_read('H:/Shared drives/DC Mapping/gisdata/planet_priority_areas/beacons_study_region.shp') %>%
#    st_transform(3579)
#grid = st_as_stars(st_bbox(x), dx = 20000, dy = 20000)
#grid = st_as_sf(grid) %>% st_cast('MULTIPOLYGON')
#grid = grid[x, ]
#grid = mutate(grid, id=1:nrow(grid), area_km2=as.numeric(st_area(grid)/1000000), values=NULL, group=1)
#st_write(grid, 'H:/Shared drives/DC Mapping/gisdata/planet_priority_areas/beacons_study_region_grid.shp', delete_layer=T)
