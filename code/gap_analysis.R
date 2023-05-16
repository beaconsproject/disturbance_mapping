# Calculate min and max image date (year) for each grid cell
# There are 10x10 cells per 1:50k grid
# PV 2023-01-08

library(sf)
library(dplyr)

#input <- 'data/yt_nts_n13_sub.shp'
#output <- '../../gisdata/YT2/gap_analysis/yt_nts_n13_sub_year.shp'
input <- 'data/fda9_nts_n13.shp'
output <- 'data/fda9_nts_n13_year.shp'

v <- st_read(input) %>% 
    st_transform(3578)
v <- mutate(v, id=1:nrow(v))
af <- st_read('../../gisdata/YT2/YG_SurfaceDisturbance/YG_SurfaceDisturbance_July2022.gdb', 'SD_Polygon') %>%
    st_transform(3578) %>%
    mutate(year=ifelse(is.na(IMAGE_DATE),9999,substr(IMAGE_DATE,1,4)))
lf <- st_read('../../gisdata/YT2/YG_SurfaceDisturbance/YG_SurfaceDisturbance_July2022.gdb', 'SD_Line') %>%
    st_transform(3578) %>%
    mutate(year=ifelse(is.na(IMAGE_DATE),9999,substr(IMAGE_DATE,1,4)))

# Tabulate number of disturbance types
table(af$TYPE_DISTURBANCE, af$TYPE_INDUSTRY)
table(lf$TYPE_DISTURBANCE, lf$TYPE_INDUSTRY)

xa <- st_intersection(af, v) %>%
    select(id, year) %>%
    st_drop_geometry()
xa <- group_by(xa, id) %>%
    summarize(areal_min=min(year),
              areal_max=max(year))

xl <- st_intersection(lf, v) %>%
    select(id, year) %>%
    st_drop_geometry()
xl <- group_by(xl, id) %>%
    summarize(linear_min=min(year),
              linear_max=max(year))

vv <- st_drop_geometry(v)
va <- left_join(vv, xa)
val <- left_join(va, xl)
val_minmax <- rowwise(val) %>% mutate(year_min=min(areal_min, linear_min, na.rm=T),
    year_max=max(areal_max, linear_max, na.rm=T)) # takes about 30 minutes
val_mm <- mutate(val_minmax, areal_min=NULL, areal_max=NULL, linear_min=NULL, linear_max=NULL)
val_year <- left_join(v, val_mm)

st_write(val_year, output, delete_layer=T)

#va <- left_join(v, xa) %>%
#    mutate(year_min=as.numeric(ifelse(is.na(year_min),0,year_min)),
#    year_max=as.numeric(ifelse(is.na(year_max),0,year_max)),
#    diff=year_max-year_min)
#vl <- left_join(v, xl) %>%
#    mutate(year_min=as.numeric(ifelse(is.na(year_min),0,year_min)),
#    year_max=as.numeric(ifelse(is.na(year_max),0,year_max)),
#    diff=year_max-year_min)

# COMBINE AND TAKE MINIMUM AND MAXIMUM ACROSS LINEAR AND AREAL FEATURES

#st_write(va, '../../gisdata/YT2/gap_analysis/yt_nts_n10_areal_year.shp', delete_layer=T)
#st_write(vl, '../../gisdata/YT2/gap_analysis/yt_nts_n10_linear_year.shp', delete_layer=T)
