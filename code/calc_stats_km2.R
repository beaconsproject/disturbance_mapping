# Calculate various 1-km2 stats using YG disturbance data
# PV 2023-02-06

library(sf)
library(dplyr)
library(stars)

bnd <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Yukon_Planning_Regions_250k') %>%
    filter(PLANNING_REGION_NAME=='Kaska Dena')
line <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_Line')
poly <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_Poly') %>%
    st_cast('MULTIPOLYGON')
extent <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_MappingExtent') %>%
    st_cast('MULTIPOLYGON')

extent <- st_intersection(extent, bnd)

# Create 1-km2 grid
#bnd <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Yukon_Planning_Regions_250k')
grid = st_as_stars(st_bbox(bnd), dx=10000, dy=10000)
grid = st_as_sf(grid) %>% st_cast('MULTIPOLYGON')
grid = grid[bnd,]
#st_write(grid, 'data/yt_disturbances.gpkg', 'Grid_10k', delete_layer=T)
#grid <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Grid_1k')
#grid <- grid[bnd,]
grid <- mutate(grid, id=as.numeric(rownames(grid)), values=NULL)

# Linear disturbances sum length (and area for buffers)
xline1 <- st_union(line)
xline2 <- st_intersection(grid, xline1)
st_write(xline2, 'data/tmp/kd_disturbances.gpkg', 'line', delete_layer=T)
xline3 <- mutate(xline2, 
    line_m=round(st_length(xline2),2), # recalculate length
    #line_density=as.numeric(round((line_m/1000),4)), # km/km2 for 1-km2 cells
    line_density=as.numeric(round((line_m/100000),4)), # km/km2 for 10-km2 cells
    line_m=NULL) %>%
    st_drop_geometry(xline3)

# Areal disturbances - sum area by grid
xpoly1 <- st_union(poly) # necessary to avoid double counting areas of overlap
xpoly2 <- st_intersection(grid, xpoly1)
st_write(xpoly2, 'data/tmp/kd_disturbances.gpkg', 'poly', delete_layer=T)
xpoly3 <- mutate(xpoly2, 
    area_m2=st_area(xpoly2), # recalculate area
    #area_pct=as.numeric(round(area_m2/1000000*100,4)), # 1-km2
    poly_pct=as.numeric(round(area_m2/100000000*100,4)), # 10-km2
    area_m2=NULL) %>%
    st_drop_geometry(xpoly3)

# Extent
x1 <- st_union(extent) # necessary to avoid double counting areas of overlap
x2 <- st_intersection(grid, x1)
#st_write(xpoly2, 'data/tmp/kd_disturbances.gpkg', 'poly', delete_layer=T)
x3 <- mutate(x2, 
    area_m2=st_area(x2), # recalculate area
    #area_pct=as.numeric(round(area_m2/1000000*100,4)), # 1-km2
    extent_pct=as.numeric(round(area_m2/100000000*100,4)), # 10-km2
    area_m2=NULL) %>%
    st_drop_geometry(x3)

# Create and populate results table
tib <- tibble(id=grid$id,grid_km2=100)
tib <- left_join(tib, xpoly3) %>%
    left_join(xline3) %>%
    left_join(x3)

#tib <- tib %>% mutate(forest_pct=ifelse(forest_pct==0,NA,forest_pct))

# Join and save
grids <- left_join(grid, tib)
st_write(bnd, 'data/yg_kd_disturbances.gpkg', 'bnd', delete_layer=T)
st_write(grid, 'data/yg_kd_disturbances.gpkg', 'grid', delete_layer=T)
st_write(grids, 'data/yg_kd_disturbances.gpkg', 'km2_stats', delete_layer=T)
st_write(extent, 'data/yg_kd_disturbances.gpkg', 'extent', delete_layer=T)