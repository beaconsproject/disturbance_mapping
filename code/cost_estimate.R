library(sf)
library(dplyr)

ipca <- st_read('../../gisdata/123/kdtt.gdb', 'lfn_ipca')

lr <- filter(ipca, Id==1)
tb <- filter(ipca, Id==2)

st_write(lr, 'little_rancheria.gpkg', delete_layer=T)
st_write(tb, 'tu_ball.gpkg', delete_layer=T)
