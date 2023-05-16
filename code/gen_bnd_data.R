# Create data packages for digitizing
# Priority FDAs: 10AB, 10AD, 10BC, 10AA
# PV 2023-02-10

library(sf)
library(dplyr)

# Select project boundary and name (FDA, Caribou range, grid cells, etc.)
fda <- 'FL_planR'
out_dir <- paste0('data/regions/',fda,'/')
canada_gpkg <- "C:/Users/PIVER37/Documents/gisdata/123/canada.gpkg"
bnd <- st_read(paste0('data/regions/',fda,'/',fda,'.shp')) %>%
    st_transform(3579)

# Input data to select or clip
nts <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','NTS_50k')
line <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_Line')
line <- mutate(line, Length_km=round(st_length(line)/1000,2))
poly <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_Poly') %>%
    st_cast('MULTIPOLYGON')
poly <- mutate(poly, Area_ha=round(st_area(poly)/10000,2))
extent <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','SD_MappingExtent') %>%
    st_cast('MULTIPOLYGON')
fire <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Fire_History') %>%
    st_cast('MULTIPOLYGON')
access <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Canada_Access_2010')
quartz <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Quartz_Claims_50k') %>%
    st_cast('MULTIPOLYGON')
#placer <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Placer_Claims_50k')
streams <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Watercourses_50K_Canvec')
lakes_rivers <- st_read('C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb','Waterbodies_50K_Canvec')
ifl2000 <- st_read(canada_gpkg, "GIFL_2000") %>%
    st_transform(crs=3579) %>%
    st_intersection(bnd)
ifl2020 <- st_read(canada_gpkg, "GIFL_2020") %>%
    st_transform(crs=3579) %>%
    st_intersection(bnd)

# Select line and poly, and clip extent
line <- line[bnd,]
poly <- poly[bnd,]
extent <- st_intersection(extent, bnd) %>%
    st_cast('MULTIPOLYGON')

# Select or clip ancillary datasets
fire <- st_intersection(fire, bnd) %>%
    st_cast('MULTIPOLYGON')
access <- st_intersection(access, bnd)
quartz <- quartz[bnd,]
#placer <- placer[bnd,]
streams <- streams[bnd,]
lakes_rivers <- lakes_rivers[bnd,]

# Save to GPKG file
st_write(bnd, paste0(out_dir,fda,'.gpkg'), 'FDA', delete_layer=T)
st_write(nts, paste0(out_dir,fda,'.gpkg'), 'nts_50k', delete_layer=T)
st_write(line, paste0(out_dir,fda,'.gpkg'), 'Linear_Features', delete_layer=T)
st_write(poly, paste0(out_dir,fda,'.gpkg'), 'Areal_Features', delete_layer=T)
st_write(extent, paste0(out_dir,fda,'.gpkg'), 'Mapping_Extent', delete_layer=T)
st_write(fire, paste0(out_dir,fda,'.gpkg'), 'Fire_History', delete_layer=T)
st_write(quartz, paste0(out_dir,fda,'.gpkg'), 'Quartz_Claims', delete_layer=T)
#st_write(placer, paste0(out_dir,fda,'.gpkg'), 'Placer_Claims', delete_layer=T)
st_write(ifl2000, paste0(out_dir,fda,'.gpkg'), 'IFL_2000', delete_layer=T)
st_write(ifl2020, paste0(out_dir,fda,'.gpkg'), 'IFL_2020', delete_layer=T)

# Save to hydro GPKG file
st_write(streams, paste0(out_dir,fda,'_hydro.gpkg'), 'streams', delete_layer=T)
st_write(lakes_rivers, paste0(out_dir,fda,'_hydro.gpkg'), 'lake_rivers', delete_layer=T)

st_layers(paste0(out_dir,fda,'.gpkg'))
st_layers(paste0(out_dir,fda,'_hydro.gpkg'))
