# Name: Digital Road Atlas
# URL: https://alpha.gov.bc.ca/gov/content/data/geographic-data-services/topographic-data/roads
# Description: The Digital Road Atlas is a comprehensive source of authoritative road data for the Province of B.C.
# Notes: The dataset is best downloaded using an ftp client such as Filezilla (https://filezilla-project.org/)
#   FTP: ftp://ftp.geobc.gov.bc.ca/sections/outgoing/bmgs/DRA_Public/
# Downloaded: 2023-03-15
# Script run: 2023-03-20

# Load libraries
library(sf)
library(dplyr)
library(tmap)

# User-defined parameters

## Input and output files/folders
epsg <- 3005
input <- "casmada/data_raw/dgtl_road_atlas.gdb"
output <- "casmada/data/bc_data_3005.gpkg"

## Area of interest - currently 10k buffer around Central and Upper Liard sub-watersheds
v <- st_read(output, "bnd_10k") %>%
    st_transform(epsg) # project to BC Albers

## Read file
x <- st_read(input, "TRANSPORT_LINE") %>%
    st_intersection(v)

## Convert to common attributes
y <- mutate(x, TYPE_INDUSTRY='Transportation', TYPE_DISTURBANCE='Roads') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)

## Save to geopackage
st_write(y, output, "bc_roads", delete_layer=TRUE)

## Have a look at the data
tmap_mode("view")
tm_shape(v) + tm_borders() +
    tm_shape(y) + tm_lines()
