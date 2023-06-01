# Name: Harvested Areas of BC (Consolidated Cutblocks)
# URL: https://catalogue.data.gov.bc.ca/dataset/harvested-areas-of-bc-consolidated-cutblocks-
# Description: The consolidated cut blocks dataset spatially combines forest harvesting data from multiple datasets
# Downloaded: 2023-03-15
# Script run: 2023-03-20

# Load libraries
library(sf)
library(dplyr)
library(tmap)

## Input and output files/folders
epsg <- 3005
input <- "casmada/data_raw/VEG_CONSOLIDATED_CUT_BLOCKS_SP.gdb"
output <- "casmada/bc_data_3005.gpkg"

## Area of interest - currently 10k buffer around Central and Upper Liard sub-watersheds
v <- st_read(output, "bnd_10k")

## Read file
x <- st_read(input, "Cut_Block_all_BC") %>%
    st_intersection(v)

## Convert to common attributes
y <- mutate(x, TYPE_INDUSTRY='Forestry', TYPE_DISTURBANCE='Forestry') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)

## Save to geopackage
st_write(y, output, "bc_cutblocks", delete_layer=TRUE)

## Have a look at the data
tmap_mode("view")
tm_shape(v) + tm_borders() +
    tm_shape(y) + tm_fill(col='red')
