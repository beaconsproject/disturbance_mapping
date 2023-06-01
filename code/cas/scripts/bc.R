# Create base data package for BC
# EPSG: 3579
# 2023-03-20

library(sf)
library(dplyr)
library(tmap)

# Input and output files/folders
epsg <- 3579
input <- "C:/Users/PIVER37/Documents/gisdata/123/fda9.gdb"
output <- "casmada/bc_data_3005.gpkg"

# Area of interest + 10k
v0 <- st_read(input, "bnd") %>%
    st_transform(epsg)
st_write(v0, output, "bnd", delete_layer=TRUE)

# Area of interest + 10k
v1 <- st_read(input, "bnd_10k") %>%
    st_transform(epsg)
st_write(v1, output, "bnd_10k", delete_layer=TRUE)

# Central and Upper Liard FDAs
v2 <- st_read(input, "fda9") %>%
    st_transform(epsg)
st_write(v2, output, "fda9", delete_layer=TRUE)

# Central and Upper Liard NHNs
v3 <- st_read(input, "nhn18") %>%
    st_transform(epsg)
st_write(v3, output, "nhn18", delete_layer=TRUE)

