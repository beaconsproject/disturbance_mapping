# Fires
fires <- st_read(igpkg, 'fires') %>%
    #st_transform(3579) %>%
    #st_cast("MULTIPOLYGON") %>%
    st_intersection(bnd)
st_write(fires, ogpkg, "fires", delete_layer=T)
