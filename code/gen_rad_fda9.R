# Generate FDA9 geopackage
# PV 2023-03-13

library(sf)
library(dplyr)

# Select FDA9, input, and output files
ca_data <- 'C:/Users/PIVER37/Documents/gisdata/123/canada.gdb'
igpkg <- 'C:/Users/PIVER37/Documents/gisdata/123/fda9_package.gpkg'
ogpkg <- 'data/fda9.gpkg'

################################################################################
# Cross-boundary data
################################################################################

# Boundary and FDAs
fda9 <- st_read(igpkg, 'FDA9') #%>% st_transform(3579)
bnd <- st_read(igpkg, 'bnd_10k') #%>% st_transform(3579)
#bnd <- st_union(fda9)
st_write(bnd, ogpkg, 'bnd', delete_layer=T, delete_dsn=T)
st_write(fda9, ogpkg, 'fda', delete_layer=T)

# Extract and clip IFL 2000 and 2020
ifl2000 <- st_read(ca_data, "GIFL_2000") %>%
    st_transform(crs=3579) %>%
    st_intersection(bnd)
st_write(ifl2000, ogpkg, "ifl_2000", delete_layer=T)

ifl2020 <- st_read(ca_data, "GIFL_2020") %>%
    st_transform(crs=3579) %>%
    st_intersection(bnd)
st_write(ifl2020, ogpkg, "ifl_2020", delete_layer=T)

# Fires
fires <- st_read(igpkg, 'fires') %>%
    #st_transform(3579) %>%
    #st_cast("MULTIPOLYGON") %>%
    st_intersection(bnd)
st_write(fires, ogpkg, "fires", delete_layer=T)

################################################################################
# YT data
################################################################################

yt_poly <- st_read(igpkg, "yt_poly") %>%
    #st_cast('MULTIPOLYGON')
    st_intersection(bnd) %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
#poly <- mutate(poly, Area_ha=round(st_area(poly)/10000,2))
st_write(poly, ogpkg, "yt_poly", delete_layer=T)

yt_line <- st_read(igpkg, "yt_line") %>%
    st_intersection(bnd) %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
#line <- mutate(line, Length_km=round(st_length(line)/1000,2))
st_write(line, ogpkg, "yt_line", delete_layer=T)

################################################################################
# BC data
################################################################################

bc_roads <- st_read(igpkg, 'bc_roads') %>%
    st_intersection(bnd) %>%
    mutate(TYPE_INDUSTRY='Transportation', TYPE_DISTURBANCE='Roads') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
st_write(bc_roads, ogpkg, "bc_line", delete_layer=T)

bc_mines <- st_read(igpkg, 'bc_mines') %>%
    st_intersection(bnd) %>%
    mutate(TYPE_INDUSTRY='Mining', TYPE_DISTURBANCE='Mining') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
   
bc_cutblocks <- st_read(igpkg, 'bc_cutblocks_selected') %>%
    st_intersection(bnd) %>%
    mutate(TYPE_INDUSTRY='Forestry', TYPE_DISTURBANCE='Forestry') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
bc_poly <- bind_rows(bc_cutblocks, bc_mines)
st_write(bc_poly, ogpkg, "bc_poly", delete_layer=T)

# Merge YT + BC

sd_poly <- bind_rows(yt_poly, bc_poly)
st_write(sd_poly, ogpkg, "sd_poly", delete_layer=T)

sd_line <- bind_rows(yt_line, bc_roads)
st_write(sd_line, ogpkg, "sd_line", delete_layer=T)
