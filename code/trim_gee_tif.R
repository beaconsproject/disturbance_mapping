# Code to trim NA values from rasters downloaded from GEE
library(terra)

for (i in c(1984)) {
    r <- rast(paste0('../gisdata/KDTT/raster30/kdtt_lc_',i,'.tif'))
    NAflag(r) <- 0
    rt <- trim(r)
    writeRaster(rt, paste0('../gisdata/KDTT/raster30/lc_',i,'.tif'))
}
