# https://gis.stackexchange.com/questions/392505/can-i-use-r-to-do-a-buffer-inside-polygons-shrink-polygons-negative-buffer?rq=1

# METHOD 1

library(sf)

shrinkIfPossible <- function(sf, size) {
  # compute inward buffer
  sg <- st_buffer(st_geometry(sf), -size)
  
  # update geometry only if polygon is not degenerate
  st_geometry(sf)[!st_is_empty(sg)] = sg[!st_is_empty(sg)]
   
  # return updated dataset
  return(sf)
}

shp_buffered <- shrinkIfPossible(shpA, 10)


# METHOD 2

library(rgeos)

# use readOGR() or shapefile() to read SpatialPolygonsDataFrame from .shp file
shpA = shapefile(file.path(PATH_DATA, 'sample_test_A.shp')) # or:
shpA = readOGR(file.path(PATH_DATA, 'sample_test_A.shp'))

# plot original polygon
plot(shpA, col='blue')

# create and plot shrinked polygon
shpA_buffered = gBuffer(shpA, width=-30)
plot(shpA_buffered, add = T, col='red')