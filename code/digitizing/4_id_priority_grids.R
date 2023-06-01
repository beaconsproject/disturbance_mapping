# Prioritizing 1-km grids to digitize based on YG and SPOT years
# PV 2023-02-22

library(sf)
library(dplyr)

# FDA 10AD
fda <- '10AD'
out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects//FDA_',fda,'/')

extent <- st_read(paste0(out_dir,'Data_package.gpkg'), 'YG_MappingExtent') %>%
    filter(MAIN_YEARS=='2014-2016')
grid100k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_100k')
grid1k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_1k')
grid100k_priority <- grid100k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid1k_priority <- grid1k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid100k <- left_join(grid100k, grid100k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))
grid1k <- left_join(grid1k, grid1k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))

st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)


# FDA 10BC
fda <- '10BC'
out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects//FDA_',fda,'/')

extent <- st_read(paste0(out_dir,'Data_package.gpkg'), 'YG_MappingExtent') %>%
    filter(MAIN_YEARS=='2014-2016')
grid100k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_100k')
grid1k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_1k')
grid100k_priority <- grid100k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid1k_priority <- grid1k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid100k <- left_join(grid100k, grid100k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))
grid1k <- left_join(grid1k, grid1k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))

st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)


# FDA 10AA001
fda <- '10AA_001'
out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects//FDA_',fda,'/')

extent1 <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb', 'Yukon_Planning_regions_250k')
extent2 <- st_read(paste0(out_dir,'Data_package.gpkg'), 'YG_MappingExtent') %>%
    filter(MAIN_YEARS=='2014-2016')
grid100k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_100k')
grid1k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_1k')
grid100k_priority <- grid100k[extent1,]
grid100k_priority <- grid100k[extent2,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid1k_priority <- grid1k[extent1,]
grid1k_priority <- grid1k[extent2,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid100k <- left_join(grid100k, grid100k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))
grid1k <- left_join(grid1k, grid1k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))

st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)


# FDA 10AA002
fda <- '10AA_002'
out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects//FDA_',fda,'/')

extent <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb', 'Yukon_Planning_regions_250k')
#extent <- st_read(paste0(out_dir,'Data_package.gpkg'), 'YG_MappingExtent') %>%
#    filter(MAIN_YEARS=='2014-2016')
grid100k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_100k')
grid1k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_1k')
grid100k_priority <- grid100k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid1k_priority <- grid1k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid100k <- left_join(grid100k, grid100k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))
grid1k <- left_join(grid1k, grid1k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))

st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)


# Klaza
fda <- 'Klaza'
out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects/',fda,'/')

grid100k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_100k')
grid100k_priority <- st_read('digitizing/klaza/Grid_100k_Klaza.gpkg') %>%
    st_drop_geometry() %>%
    rename(id=values, priority=Priority) %>%
    mutate(id=grid100k$id,
        priority=ifelse(priority==2,0,priority))
grid100k <- left_join(grid100k, grid100k_priority)

grid1k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_1k')
extent <- filter(grid100k, priority==1)
grid1k_priority <- grid1k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid1k <- left_join(grid1k, grid1k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))

st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)

# Clear Creek
fda <- 'Clear_Creek'
out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects/',fda,'/')

grid100k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_100k')
grid100k_priority <- st_read('digitizing/clear_creek/Grid_100k_ClearCreek.gpkg') %>%
    st_drop_geometry() %>%
    rename(id=values, priority=Priority) %>%
    mutate(id=grid100k$id,
        priority=ifelse(priority==2,0,priority))
grid100k <- left_join(grid100k, grid100k_priority)

grid1k <- st_read(paste0(out_dir,'Data_package.gpkg'), 'Grid_1k')
extent <- filter(grid100k, priority==1)
grid1k_priority <- grid1k[extent,] %>%
    mutate(priority=1, values=NULL, status=NULL) %>%
    st_drop_geometry()
grid1k <- left_join(grid1k, grid1k_priority) %>%
    mutate(priority=ifelse(is.na(priority),0,priority))

st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)
