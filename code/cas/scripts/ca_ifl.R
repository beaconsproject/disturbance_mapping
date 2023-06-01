# Intact forest landscapes
# URL: intactforests.org
# Downloaded: 2023-03-21

# Step 1 - Define AOI
aoi <- st_read('data/c

# Step 2 - Download and unzip IFL 2000 and 2020 into temp folder
zifl2000 <- 'tmp/IFL_2000.shp'
zifl2020 <- 'tmp/IFL_2020.shp'

# Step 3 - Extract, project, and clip to AOI
ifl2000 <- st_read(ca_data, "GIFL_2000") %>%
    st_transform(crs=3579) %>%
    st_intersection(bnd)
ifl2020 <- st_read(ca_data, "GIFL_2020") %>%
    st_transform(crs=3579) %>%
    st_intersection(bnd)

# Step 4 - Save to geopackage
st_write(ifl2000, ogpkg, "ifl_2000", delete_layer=T)
st_write(ifl2020, ogpkg, "ifl_2020", delete_layer=T)

