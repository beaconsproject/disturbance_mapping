# Summarizing layers and attributes in the data_package.gpkg
# 2026-06-23

library(sf)
library(tidyverse)

# Check layers in data_package.gpkg
st_layers("disturbance_mapping/template/data_package.gpkg")

Driver: GPKG 
Available layers:
  layer_name geometry_type features fields             crs_name
1    bp_line                      0     21 NAD83 / Yukon Albers
2    bp_poly                      0     20 NAD83 / Yukon Albers

# Check attributes in bp_line
line <- st_read("disturbance_mapping/template/data_package.gpkg", "bp_line")
glimpse(line)

Rows: 0
Columns: 22
$ REF_ID             <chr> 
$ DATABASE           <chr> 
$ TYPE_INDUSTRY      <chr> 
$ TYPE_DISTURBANCE   <chr> 
$ WIDTH_M            <dbl> 
$ WIDTH_CLASS        <chr> 
$ SCALE_CAPTURED     <int> 
$ DATA_SOURCE        <chr> 
$ IMAGE_NAME         <chr> 
$ IMAGE_DATE         <dttm> 
$ IMAGE_RESOLUTION   <dbl> 
$ IMAGE_SENSOR       <chr> 
$ CREATED_BY         <chr> 
$ CREATED_DATE       <chr> 
$ FEATURE_VISIBILITY <chr> 
$ DISTURBANCE_YEAR   <dbl> 
$ FLAG               <chr> 
$ FLAG_YG            <chr> 
$ VHR_ASSIST         <chr> 
$ NOTES              <chr> 
$ Shape_Length       <dbl> 
$ geom               <GEOMETRY [m]> 

# Check attributes in bp_poly
poly <- st_read("disturbance_mapping/template/data_package.gpkg", "bp_poly")
glimpse(poly)

Rows: 0
Columns: 21
$ REF_ID             <chr> 
$ DATABASE           <chr> 
$ TYPE_INDUSTRY      <chr> 
$ TYPE_DISTURBANCE   <chr> 
$ SCALE_CAPTURED     <int> 
$ DATA_SOURCE        <chr> 
$ IMAGE_NAME         <chr> 
$ IMAGE_DATE         <dttm> 
$ IMAGE_RESOLUTION   <dbl> 
$ IMAGE_SENSOR       <chr> 
$ CREATED_BY         <chr> 
$ CREATED_DATE       <chr> 
$ FEATURE_VISIBILITY <chr> 
$ DISTURBANCE_YEAR   <dbl> 
$ FLAG               <chr> 
$ FLAG_YG            <chr> 
$ VHR_ASSIST         <chr> 
$ NOTES              <chr> 
$ Shape_Length       <dbl> 
$ Shape_Area         <dbl> 
$ geom               <GEOMETRY [m]> 
