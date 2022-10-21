# Generate FDA geopackages
# PV 2022-08-30

library(sf)
library(dplyr)

# Select FDA, input, and output files
yg_dir <- "C:/Users/PIVER37/Documents/gisdata/YT/"
canada_gpkg <- "C:/Users/PIVER37/Documents/gisdata/123/canada.gpkg"
yg_gpkg <- "C:/Users/PIVER37/Documents/github/dc-mapping/data/yg_disturbances.gpkg"
fda_list <- c("09EA","10AB")
fda_list <- "10AB"

for (fda_name in fda_list) {
    fda_gpkg <- paste0("C:/Users/PIVER37/Documents/github/dc-mapping/data/fda_",tolower(fda_name),".gpkg")

    # Select one FDA
    x <- st_read(canada_gpkg, 'NHN_Index') %>%
        filter(FDA==fda_name)
    fda <- st_transform(x, crs=3578)

    # Write to geopackage file
    st_write(fda, fda_gpkg, "FDA", delete_layer=T, delete_dsn=T)

    # Extract and clip IFL 2000 and 2020
    ifl2000 <- st_read(canada_gpkg, "GIFL_2000") %>%
        st_intersection(x) %>%
        st_transform(crs=3578)
    st_write(ifl2000, fda_gpkg, "IFL_2000", delete_layer=T)

    ifl2020 <- st_read(canada_gpkg, "GIFL_2020") %>%
        st_intersection(x) %>%
        st_transform(crs=3578)
    st_write(ifl2020, fda_gpkg, "IFL_2020", delete_layer=T)

    # YG surface disturbance
    extent <- st_read(yg_gpkg, "SD_MappingExtent") %>% st_cast("MULTIPOLYGON") %>%
        st_intersection(st_union(fda))
    st_write(extent, fda_gpkg, "Mapping_Extent", delete_layer=T)

    areal <- st_read(yg_gpkg, "SD_Polygon") %>%
        st_intersection(st_union(fda))
    areal <- mutate(areal, Area_ha=round(st_area(areal)/10000,2))
    st_write(areal, fda_gpkg, "Areal_Features", delete_layer=T)

    linear <- st_read(yg_gpkg, "SD_Line") %>%
        st_intersection(st_union(fda))
    linear <- mutate(linear, Length_km=round(st_length(linear)/1000,2))
    st_write(linear, fda_gpkg, "Linear_Features", delete_layer=T)

    point <- st_read(yg_gpkg, "SD_Point") %>%
        st_intersection(st_union(fda))
    st_write(point, fda_gpkg, "Point_Features", delete_layer=T)

    # Fires
    fire_pts <- st_read(paste0(yg_dir,'Emergency_Management/Fire_Ignition_Locations.gdb'), 'Fire_Ignition_Locations') %>%
        select(FIRE_ID,GENERAL_FIRE_CAUSE) %>%
        st_drop_geometry()

    fires <- st_read(paste0(yg_dir,'Emergency_Management/Fire_History.gdb'), 'Fire_History') %>%
        st_cast("MULTIPOLYGON") %>%
        st_intersection(st_union(fda)) %>%
        left_join(fire_pts)
    st_write(fires, fda_gpkg, "Fire_History", delete_layer=T)

    # Claims
    quartz <- st_read(paste0(yg_dir,'Mining/Quartz_Claims_50k.gdb'), 'Quartz_Claims_50k') %>%
        st_cast("MULTIPOLYGON") %>%
        st_intersection(st_union(fda))
    st_write(quartz, fda_gpkg, "Quartz_Claims", delete_layer=T)

    # NTS 50K grid
    nts <- st_read(canada_gpkg, "NTS_50k") %>%
        st_transform(3578)
    nts <- nts[fda,]
    st_write(nts, fda_gpkg, "nts_50k", delete_layer=T)

    # Hydrology

}
