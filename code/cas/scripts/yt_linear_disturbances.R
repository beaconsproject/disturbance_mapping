yt_line <- st_read(igpkg, "yt_line") %>%
    st_intersection(bnd) %>%
    select(TYPE_INDUSTRY, TYPE_DISTURBANCE)
#line <- mutate(line, Length_km=round(st_length(line)/1000,2))
st_write(line, ogpkg, "yt_line", delete_layer=T)
