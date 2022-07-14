# Calculate watershed intactness
# PV 2022-04-17

library(sf)
library(dplyr)
library(rmapshaper)

vecReg <- 'C:/Users/PIVER37/Dropbox (BEACONs)/dc_mapping/gisdata/FDA/region.gpkg'
fda <- st_read(vecReg, 'fda') %>% select(FDA==i)
i2020 <- st_read(vecReg, 'ifl_2020')
tb <- tibble(FDA=fda$FDA, fda_km2=0, ifl_km2=0, ifl_pct=0)
for (i in fda$FDA) {
    print(i); flush.console()
    y <- filter(fda, FDA==i)
    z <- ms_clip(i2020, y) %>% st_union()
    tb$fda_km2[tb$FDA==i] <- round(st_area(y)/1000000,1)
    tb$ifl_km2[tb$FDA==i] <- round(sum(st_area(z))/1000000,1)
    tb$ifl_pct[tb$FDA==i] <- round(st_area(z)/sum(st_area(y))*100,1)
}

fda_tb <- left_join(fda, tb)
st_write(fda_tb, 'data/fda_intactness.gpkg')
