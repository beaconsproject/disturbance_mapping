# fda_10ab.md Metadata

################################################################################
## FDA_10AB.gpkg Layers

Available layers:
         layer_name geometry_type features fields             crs_name
1               FDA Multi Polygon        1     19 NAD83 / Yukon Albers
2          IFL_2000 Multi Polygon        2     24 NAD83 / Yukon Albers
3          IFL_2020 Multi Polygon        2     23 NAD83 / Yukon Albers
4    Mapping_Extent       Polygon        2      4 NAD83 / Yukon Albers
5    Areal_Features                    127     13 NAD83 / Yukon Albers
6   Linear_Features                    587     14 NAD83 / Yukon Albers
7    Point_Features                      0     10 NAD83 / Yukon Albers
8      Fire_History                     46     12 NAD83 / Yukon Albers
9     Quartz_Claims                   5077     16 NAD83 / Yukon Albers
10          nts_50k Multi Polygon       31      6 NAD83 / Yukon Albers
11  Areal_Features+       Polygon      506      5 NAD83 / Yukon Albers
12 Linear_Features+                   1034      5 NAD83 / Yukon Albers

### Areal_Features+ Attributes

TYPE_INDUSTRY
TYPE_DISTURBANCE
CREATED_BY
IMAGE_DATA
Length_km
geom

### Linear_Features+ Attributes

TYPE_INDUSTRY
TYPE_DISTURBANCE
CREATED_BY
IMAGE_DATA
Length_km
geom

################################################################################
# fda_10ab_shp folder

Shapefiles:
 - fda.shp
 - areal_disturbances.shp
 - linear_disturbances.shp

Note that the shapefiles have shortened field names for the following:
 - INDUSTRY = TYPE_INDUSTRY
 - DISTURB = TYPE_DISTURBANCE
 - DATE = IMAGE_DATE
 - Len_km = Length_km
