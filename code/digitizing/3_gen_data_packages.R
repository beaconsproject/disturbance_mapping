# Create data packages for digitizing
# Priority FDAs: 10AB, 10AD, 10BC, 10AA
# PV 2023-02-21

library(sf)
library(dplyr)
library(stars)

# Select grid type
#gtype <- 'equal_area' # 'equal_area' or 'nts_nested' i.e., nested within NTS_50k grid
#gsize <- '1000' # metres
#ncells <- 25 # number of nested cells e.g., 9x9

#for (fda in c('10AB', '10AD', '10BC', '10AA', 'Klaza', 'Clear_Creek')) {
for (fda in c('10AA001','10AA002')) {
    cat('Processing',fda,'...\n'); flush.console()
    if (fda %in% c('Klaza','Clear_Creek')) {
        out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects/',fda,'/')
        bnd <- st_read('H:/Shared drives/DC Mapping/gisdata/Maegan_study_region/caribou_mapping_boundaries.shp') %>%
            st_transform(3579)
        bnd$id <- c(1,2)
        if (fda=='Klaza') {
            bnd <- filter(bnd, id==1)
        } else {
            bnd <- filter(bnd, id==2)
        }
    } else if (fda %in% c('10AA001','10AA002')) {
        out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects/FDA_',fda,'/')
        bnd <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb', 'nhn18') %>%
            filter(DATASETNAM==fda)
    } else {
        out_dir <- paste0('H:/Shared drives/Disturbance Mapping (digitizing)/Projects/FDA_',fda,'/')
        bnd <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb', 'fda9') %>%
            filter(FDA==fda)
    }

    # Input data to select or clip
    nts <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','NTS_50k')
    line <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_Line')
    poly <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_Poly') %>%
        st_cast('MULTIPOLYGON')
    extent <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_MappingExtent') %>%
        st_cast('MULTIPOLYGON')
    fire <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Fire_History') %>%
        st_cast('MULTIPOLYGON')
    access <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Canada_Access_2010')
    quartz <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Quartz_Claims_50k') %>%
        st_cast('MULTIPOLYGON')
    placer <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Placer_Claims_50k')
    spot <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SPOT_Metadata_2021')
    streams <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Watercourses_50k_Canvec')
    roads <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Yukon_Road_network')
    med <- st_read('C:/Users/PIVER37/Documents/gisdata/YT/Imagery/Footprints_Medium_Resolution_Satellites.gdb','Footprints_Medium_Resolution_Satellites') %>%
        st_transform(3579)
    high <- st_read('C:/Users/PIVER37/Documents/gisdata/YT/Imagery/Footprints_High_Resolution_Satellites.gdb','Footprints_High_Resolution_Satellites') %>%
        st_transform(3579)
    grid100 <- st_read('digitizing/grid_100k.gpkg')

    # Select line and poly, and clip extent
    line <- line[bnd,]
    poly <- poly[bnd,]
    extent <- st_intersection(extent, bnd) %>%
        st_cast('MULTIPOLYGON')

    # Create emply line and poly layers for digitizing new features
    if (fda=='10AB') {
        line_bp <- st_read('digitizing/fda_10ab/surface_disturbances.gpkg', 'BP_Line')
        poly_bp <- st_read('digitizing/fda_10ab/surface_disturbances.gpkg', 'BP_Poly')
    } else if (fda=='Klaza') {
        line_bp <- st_read('digitizing/klaza/surface_disturbances.gpkg', 'BP_Line')
        poly_bp <- st_read('digitizing/klaza/surface_disturbances.gpkg', 'BP_Poly')
    } else {
        line_bp <- filter(line, row_number()==1) %>%
            mutate(CREATED_BY="", CREATED_DATE="", FEATURE_VISIBILITY="", 
            DISTURBANCE_YEAR=0, FLAG="", FLAG_YG="", VHR_ASSIST="", NOTES="", Shape_Length=NULL)
            #filter(DATABASE==NA)
        #line_bp <- line_bp[,c('REF_ID','DATABASE','TYPE_INDUSTRY','TYPE_DISTURBANCE','WIDTH_M','WIDTH_CLASS','SCALE_CAPTURED',
        #    'DATA_SOURCE','IMAGE_NAME','IMAGE_DATE','IMAGE_RESOLUTION','IMAGE_SENSOR',
        #    'CREATED_BY','CREATED_DATE','FEATURE_VISIBILITY',
        #    'DISTURBANCE_YEAR','FLAG','FLAG_YG','VHR_ASSIST','NOTES')]
        poly_bp <- filter(poly, row_number()==1) %>%
            mutate(CREATED_BY="", CREATED_DATE="", FEATURE_VISIBILITY="", 
            DISTURBANCE_YEAR=0, FLAG="", FLAG_YG="", VHR_ASSIST="", NOTES="", Shape_Area=NULL, Shape_Length=NULL)
            #filter(DATABASE==NA)
        #poly_bp <- poly_bp[,c('REF_ID','DATABASE','TYPE_INDUSTRY','TYPE_DISTURBANCE','SCALE_CAPTURED',
        #    'DATA_SOURCE','IMAGE_NAME','IMAGE_DATE','IMAGE_RESOLUTION','IMAGE_SENSOR',
        #    'CREATED_BY','CREATED_DATE','FEATURE_VISIBILITY',
        #    'DISTURBANCE_YEAR','FLAG','FLAG_YG','VHR_ASSIST','NOTES')]
    }

    # Select or clip ancillary datasets
    fire <- st_intersection(fire, bnd) %>%
        st_cast('MULTIPOLYGON')
    access <- st_intersection(access, bnd)
    nts <- nts[bnd,]
    quartz <- quartz[bnd,]
    placer <- placer[bnd,]
    spot <- st_intersection(spot, bnd) %>%
        st_cast('MULTIPOLYGON')
    med <- st_intersection(med, bnd) %>%
        st_cast('MULTIPOLYGON')
    high <- st_intersection(high, bnd) %>%
        st_cast('MULTIPOLYGON')
    streams <- streams[bnd,]
    roads <- roads[bnd,]

    # Create grid
    #if (gtype=='equal_area') {
        #grid100k = st_as_stars(st_bbox(bnd), dx=10000, dy=10000)
        #grid100k = st_as_sf(grid100k) %>% st_cast('MULTIPOLYGON')
        grid100k = grid100[bnd,]
        #grid100k <- rename(grid100k, status=values)
        #grid1k = st_as_stars(st_bbox(bnd), dx=1000, dy=1000)
        grid1k = st_as_stars(st_bbox(grid100k), dx=1000, dy=1000)
        grid1k = st_as_sf(grid1k) %>% st_cast('MULTIPOLYGON')
        grid1k = grid1k[bnd,]
        grid1k = mutate(grid1k, id=1:nrow(grid1k)) %>%
            rename(status=values)
        #grid1k <- rename(grid1k, status=values)
    #} else if (gtype=='nts_nested') {
    #    nts_xy <- st_transform(nts, 4326)
    #    lst <- list()
    #    for(i in nts_xy$NTS_SNRC){
    #      nts_i <- nts_xy[nts$NTS_SNRC == i,] # subset nts
    #      grd_i_sfc <- st_make_grid(nts_i, n = ncells) # make smaller grids nested in nts
    #      grd_i <- st_sf(nts = i, geometry = grd_i_sfc) # convert geometries to sf object
    #      lst <- append(lst, list(grd_i))
    #    }
    #    full_grid <- do.call(rbind, lst)
    #    full_grid_prj <- st_transform(full_grid, st_crs(nts))
    #    grid <- mutate(full_grid_prj, area_m2=st_area(full_grid_prj), status=0)
    #    grid <- grid[bnd,]
    #} else {
    #    stop('gtype must be either "equal_area" or "nts_nested"')
    #}

    # Save to GPKG file
    st_write(bnd, paste0(out_dir,'Data_package.gpkg'), 'Boundary', delete_layer=T)
    st_write(grid100k, paste0(out_dir,'Data_package.gpkg'), 'Grid_100k', delete_layer=T)
    st_write(grid1k, paste0(out_dir,'Data_package.gpkg'), 'Grid_1k', delete_layer=T)
    st_write(line_bp, paste0(out_dir,'Data_package.gpkg'), 'BP_Line', delete_layer=T)
    st_write(poly_bp, paste0(out_dir,'Data_package.gpkg'), 'BP_Poly', delete_layer=T)
    st_write(line, paste0(out_dir,'Data_package.gpkg'), 'YG_Line', delete_layer=T)
    st_write(poly, paste0(out_dir,'Data_package.gpkg'), 'YG_Poly', delete_layer=T)
    st_write(extent, paste0(out_dir,'Data_package.gpkg'), 'YG_MappingExtent', delete_layer=T)
    st_write(fire, paste0(out_dir,'Data_package.gpkg'), 'Fire_History', delete_layer=T)
    st_write(access, paste0(out_dir,'Data_package.gpkg'), 'Canada_Access_2010', delete_layer=T)
    st_write(quartz, paste0(out_dir,'Data_package.gpkg'), 'Quartz_Claims_50k', delete_layer=T)
    st_write(placer, paste0(out_dir,'Data_package.gpkg'), 'Placer_Claims_50k', delete_layer=T)
    st_write(streams, paste0(out_dir,'Data_package.gpkg'), 'Watercourses_50k_Canvec', delete_layer=T)
    st_write(spot, paste0(out_dir,'Data_package.gpkg'), 'SPOT_Metadata_2021', delete_layer=T)
    st_write(med, paste0(out_dir,'Data_package.gpkg'), 'MedRes_Metadata', delete_layer=T)
    st_write(high, paste0(out_dir,'Data_package.gpkg'), 'HighRes_Metadata', delete_layer=T)
    st_write(roads, paste0(out_dir,'Data_package.gpkg'), 'Yukon_Road_Network', delete_layer=T)
    st_delete(paste0(out_dir,'Data_package.gpkg'), 'PV_Line')
}

st_layers(paste0(out_dir,'Data_package.gpkg'))
