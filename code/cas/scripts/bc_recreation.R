# BC Recreation Lines
# URL: https://catalogue.data.gov.bc.ca/dataset/recreation-line
# Downloaded: 2023-03-15
# Script run: 2023-03-20

# Load libraries
library(sf)
library(dplyr)
library(tmap)

# User-defined parameters

## Input and output files/folders
epsg <- 3005
input <- "casmada/data_raw/FTEN_RECREATION_LINES_SVW.gdb"
output <- "casmada/data/bc_data_3005.gpkg"

## Area of interest - currently 10k buffer around Central and Upper Liard sub-watersheds
v <- st_read(output, "bnd_10k") %>%
    st_transform(epsg) # project to BC Albers

## Read file
x <- st_read(input, "WHSE_FOREST_TENURE_FTEN_RECREATION_LINES_SVW") %>%
    st_intersection(v)

## Convert to common attributes
y <- mutate(x, TYPE_INDUSTRY='Transportation', TYPE_DISTURBANCE='Trails') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)

## Save to geopackage
st_write(y, output, "bc_trails", delete_layer=TRUE)

## Have a look at the data
tmap_mode("view")
tm_shape(v) + tm_borders() +
    tm_shape(y) + tm_lines()
