# Generate Liard River Basin geopackage (lrb.gpkg) - EPSG:102001
# PV 2023-05-17

library(sf)
library(dplyr)

setwd('code/cas')

# Select FDA9, input, and output files
gdb <- 'C:/Users/PIVER37/Documents/gisdata/123/lrb.gdb'
gpkg <- 'C:/Users/PIVER37/Documents/gisdata/123/lrb.gpkg'

################################################################################
# Cross-boundary data
################################################################################

# Boundary and FDAs
fda <- st_read(gdb, 'fda')
bnd <- st_read(gdb, 'bnd_10k')
ca <- st_read(gdb, 'canada')
st_write(bnd, gpkg, 'bnd', delete_layer=T, delete_dsn=T)
st_write(fda, gpkg, 'fda', delete_layer=T)
st_write(ca, gpkg, 'canada', delete_layer=T)

# Extract and clip IFL 2020
ifl2020 <- st_read(gdb, "global_ifl_2020") %>%
    st_intersection(bnd) %>%
    st_cast("MULTIPOLYGON")
st_write(ifl2020, gpkg, "ifl_2020", delete_layer=T)

# Fires
fires <- st_read(gdb, 'fires') %>%
    st_intersection(bnd) %>%
    st_cast("MULTIPOLYGON")
st_write(fires, gpkg, "fires", delete_layer=T)

################################################################################
# YT data
################################################################################

yt_poly <- st_read(gdb, "yt_poly") %>%
    st_cast("MULTIPOLYGON") %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE) %>%
    mutate(LOCATION='YT') %>%
    rename(GEOMETRY=SHAPE)

yt_line <- st_read(gdb, "yt_line") %>%
    st_cast("MULTILINESTRING") %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE) %>%
    mutate(LOCATION='YT') %>%
    rename(GEOMETRY=geom)

################################################################################
# BC data
################################################################################

bc_line <- st_read(gdb, 'bc_roads') %>%
    mutate(TYPE_INDUSTRY='Transportation', TYPE_DISTURBANCE='Roads', LOCATION='BC') %>%
    st_cast("MULTILINESTRING") %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE, LOCATION)

bc_mines <- st_read(gdb, 'bc_mines') %>%
    st_cast("MULTIPOLYGON") %>%
    mutate(TYPE_INDUSTRY='Mining', TYPE_DISTURBANCE='Mining', LOCATION='BC') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE, LOCATION) %>%
    rename(GEOMETRY=Shape)
   
bc_cutblocks <- st_read(gdb, 'bc_cutblocks') %>%
    st_cast("MULTIPOLYGON") %>%
    mutate(TYPE_INDUSTRY='Forestry', TYPE_DISTURBANCE='Forestry', LOCATION='BC') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE, LOCATION) %>%
    rename(GEOMETRY=SHAPE)

bc_poly <- bind_rows(bc_cutblocks, bc_mines)

################################################################################
# NT data
################################################################################

nt <- st_read(gdb, 'canada') %>%
    filter(PRUID==61)
nt_poly <- st_read(gdb, 'human_access_2010') %>%
    st_intersection(nt) %>%
    st_cast("MULTIPOLYGON") %>%
    mutate(TYPE_INDUSTRY='Unknown', TYPE_DISTURBANCE='Unknown', LOCATION='NT') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE, LOCATION) %>%
    rename(GEOMETRY=Shape)

################################################################################
# AB data
################################################################################

ab_poly <- st_read(gdb, 'ab_footprint') %>%
    st_cast("MULTIPOLYGON") %>%
    mutate(TYPE_INDUSTRY='Unknown', TYPE_DISTURBANCE='Unknown', LOCATION='AB') %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE, LOCATION) %>%
    rename(GEOMETRY=Shape)

################################################################################
# Merge data
################################################################################

sd_poly <- bind_rows(yt_poly, bc_poly, nt_poly, ab_poly)
st_write(sd_poly, gpkg, "sd_poly", delete_layer=T)

sd_line <- bind_rows(yt_line, bc_line)
st_write(sd_line, gpkg, "sd_line", delete_layer=T)

################################################################################
# Buffer all linear and areal feature by 500m (except human_access_2010)
################################################################################

yt_poly500 <- st_buffer(yt_poly, 500)
yt_line500 <- st_buffer(yt_line, 500)
bc_poly500 <- st_buffer(bc_poly, 500)
bc_line500 <- st_buffer(bc_line, 500)
ab_poly500 <- st_buffer(ab_poly, 500)
    
sd_500 <- bind_rows(yt_poly500, bc_poly500, nt_poly, ab_poly500, yt_line500, bc_line500) %>%
    st_intersection(bnd) %>%
    st_union()
st_write(sd_500, gpkg, "sd_buf500", delete_layer=T)

################################################################################
# Buffer all linear and areal features by nominal amount i.e., AB HFI
################################################################################
