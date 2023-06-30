# Convert a geodatabse (.gdb) to a geopackage (.gpkg)
# Pierre Vernier
# 2023-06-02

library(sf)
library(dply)

# Input gdb and output gpks/crs
gdb <- 'C:/Users/PIVER37/Documents/gisdata/123/lrb.gdb'
gpkg <- 'C:/Users/PIVER37/Documents/gisdata/123/lrb2.gpkg'
gpkg_crs <- 3005 # BC Albers

# Get layers in gdb
gdb_lyrs <- st_layers(gdb)$name

# List of layers to convert to gpkg
gpkg_lyrs <- c('bnd','fda','ifl_2020','fire','canada','sd_line','sd_poly','sd_buf500','nts_50k')

# Convert each layer in gdb to a layer in gpkg
i = 1
for (lyr in gdb_lyrs) {
    if (lyr %in% gpkg_lyrs) {
        x <- st_read(gdb, lyr) %>% 
            st_transform(gpkg_crs)
        if (i==1) {
            st_write(x, gpkg, lyr, delete_dsn=T)
        } else {
            st_write(x, gpkg, lyr, delete_layer=T)
        }
    }
    i = i + 1
}
