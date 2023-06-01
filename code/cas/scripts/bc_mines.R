# Name: Global-scale mining polygons (Version 2)
# URL1: https://doi.pangaea.de/10.1594/PANGAEA.942325
# URL2: https://doi.pangaea.de/10.1594/PANGAEA.928573
# Description: Land used by the global mining industry, including large-scale and artisanal and small-scale mining
# Downloaded: 2023-03-15
# Script run: 2023-03-20

# Load libraries
library(sf)
library(dplyr)
library(tmap)

# Input and output files/folders
epsg <- 3005
input <- "casmada/data_raw/global_mining_polygons_v2.gpkg"
output <- "casmada/data/bc_data_3005.gpkg"
canada <- "C:/Users/PIVER37/Documents/gisdata/123/canada.gdb"

# Area of interest - currently 10k buffer around Central and Upper Liard sub-watersheds
v <- st_read(output, "bnd_10k")
bc <- st_read(canada, 'Provinces') %>%
    filter(NAME=='BRITISH COLUMBIA') %>%
    st_transform(epsg)
    
# Read file
x <- st_read(input, "mining_polygons") %>%
    filter(COUNTRY_NAME=="Canada") %>%
    st_transform(epsg) %>%
    st_intersection(bc) %>%
    st_intersection(v)

# Convert to common attributes
y <- mutate(x, TYPE_INDUSTRY='Mining', TYPE_DISTURBANCE='Mining') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)

# Save to geopackage
st_write(y, output, "bc_mines", delete_layer=TRUE)

# Have a look at the data
tmap_mode("view")
tm_shape(v) + tm_borders() +
    tm_shape(y) + tm_fill(col='red')
