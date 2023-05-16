# Generate FDA geopackages
# PV 2023-03-10

library(sf)
library(dplyr)

# Select FDA, input, and output files
#yg_dir <- "C:/Users/PIVER37/Documents/gisdata/YT/"
ca_data <- "C:/Users/PIVER37/Documents/gisdata/123/canada.gdb"
yt_data <- "C:/Users/PIVER37/Documents/gisdata/123/yt_disturbance_mapping.gdb"
fda_list <- st_read(yt_data, 'FDA9') %>% pull(FDA)
fda_list <- c('10AA','10AB','10AD','10BC','10BD','10BE')
fdax <- c('10AA','10AD','10BC','10BD','10BE') # cross-border FDAs
kd <- st_read(yt_data,'Yukon_Planning_Regions_250k') %>%
    filter(PLANNING_REGION_NAME=='Kaska Dena')

for (fda_name in fda_list) {
    fda_gpkg <- paste0('data/fda_',tolower(fda_name),'.gpkg')

    # Boundary
    fda <- st_read(yt_data, 'FDA9') %>%
        filter(FDA==fda_name) %>%
        st_transform(3579)
    if (fda_name %in% fdax) {fda <- st_intersection(fda, kd)}
    st_write(fda, fda_gpkg, "FDA", delete_layer=T, delete_dsn=T)

    # Extract and clip IFL 2000 and 2020
    ifl2000 <- st_read(ca_data, "GIFL_2000") %>%
        st_transform(crs=3579) %>%
        st_intersection(fda)
    if (fda_name %in% fdax) {ifl2000 <- st_intersection(ifl2000, kd)}
    st_write(ifl2000, fda_gpkg, "IFL_2000", delete_layer=T)

    ifl2020 <- st_read(ca_data, "GIFL_2020") %>%
        st_transform(crs=3579) %>%
        st_intersection(fda)
    if (fda_name %in% fdax) {ifl2020 <- st_intersection(ifl2020, kd)}
    st_write(ifl2020, fda_gpkg, "IFL_2020", delete_layer=T)

    poly <- st_read(yt_data, "SD_Poly") %>%
        st_cast('MULTIPOLYGON') %>%
        st_intersection(st_union(fda))
    poly <- mutate(poly, Area_ha=round(st_area(poly)/10000,2))
    if (fda_name %in% fdax) {poly <- st_intersection(poly, kd)}
    st_write(poly, fda_gpkg, "Areal_Features", delete_layer=T)

    line <- st_read(yt_data, "SD_Line") %>%
        st_intersection(st_union(fda))
    line <- mutate(line, Length_km=round(st_length(line)/1000,2))
    if (fda_name %in% fdax) {line <- st_intersection(line, kd)}
    st_write(line, fda_gpkg, "Linear_Features", delete_layer=T)

    # Fires
    fires <- st_read(yt_data, 'Fire_History') %>%
        st_cast("MULTIPOLYGON") %>%
        st_intersection(st_union(fda))
    if (fda_name %in% fdax) {fires <- st_intersection(fires, kd)}
    st_write(fires, fda_gpkg, "Fire_History", delete_layer=T)

    # Claims
    quartz <- st_read(yt_data, 'Quartz_Claims_50k') %>%
        st_cast("MULTIPOLYGON") %>%
        st_intersection(st_union(fda))
    if (fda_name %in% fdax) {quartz <- st_intersection(quartz, kd)}
    st_write(quartz, fda_gpkg, "Quartz_Claims", delete_layer=T)

}
