# Create nested grid inside each NTS grid, then merge and project.
# n=5 = 26.8km2; n=10 = 6.7km2; n=13 ~ 2km2 (grid sizes change with lat long)
# PV 2022-11-18 (adapted from ME)

library(sf)
library(dplyr)

# Read NTS grid and project to latlong
nts <- st_read('C:/Users/PIVER37/Documents/gisdata/YT/Reference/NTS_Index_50k.gdb', 'NTS_Index_50k')
nts_xy <- st_transform(nts, 4326)

# Create 10 x 10 grid within each NTS grid
lst <- list()
for(i in nts_xy$NTS_MAP50K){
  nts_i <- nts_xy[nts$NTS_MAP50K == i,] # subset nts
  grd_i_sfc <- st_make_grid(nts_i, n = 13) # make smaller grids nested in nts
  grd_i <- st_sf(nts = i, geometry = grd_i_sfc) # convert geometries to sf object
  lst <- append(lst, list(grd_i))
}

# Merge and project back to Yukon Albers
full_grid <- do.call(rbind, lst)
full_grid_prj <- st_transform(full_grid, st_crs(nts))
full_grid_prj <- mutate(full_grid_prj, area_m2=st_area(full_grid_prj))

st_write(full_grid_prj, 'data/yt_nts_n13.shp')
