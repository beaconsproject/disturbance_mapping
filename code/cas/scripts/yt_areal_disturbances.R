yt_poly <- st_read(igpkg, "yt_poly") %>%
    #st_cast('MULTIPOLYGON')
    st_intersection(bnd) %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
#poly <- mutate(poly, Area_ha=round(st_area(poly)/10000,2))
st_write(poly, ogpkg, "yt_poly", delete_layer=T)
