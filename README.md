# Regional disturbance mapping

The goal of the regional disturbance mapping project is to develop and validate a regional-scale disturbance map for a pilot planning region in southeast Yukon and northwest BC that can be used for conservation and land use planning. Our specific objectives are to:

- To develop an anthropogenic surface disturbance database for the KDTT planning region
  - Develop regional disturbance maps using existing datasets
  - Identify spatial and temporal gaps in disturbance maps
  - Fill gaps in coverage using remote sensing imagery (digitizing)
  - Validate and update disturbance maps using high resolution remote sensing and field based data
- To develop map products based on disturbance datasets for use in conservation planning:
  - [Regional Disturbance Mapping Explorer](https://github.com/beaconsproject/RDMExplorer)

Project timelines can be viewed [here] if you have permission (https://docs.google.com/spreadsheets/d/1zUy7QgPnn-Cp8nlaxmCUR9VXAgbjTT3KI0Ad4XHlUiU/edit#gid=925452415).

## Disturbance datasets

A number of existing disturbance and related datasets exist in both Yukon and British Columbia. We are currently compiling a list of the most relevant datasets:

- [Yukon datasets](data_yt.csv)
- [BC datasets](data_bc.csv)
- [Web services](web_services.csv)

## Protocol for manual disturbance mapping

The third objective of the Regional Disturbance Mapping project is to fill gaps in the coverage of disturbances using high resolution remote sensing imagery. The procedures to do so were adapted from the YG Government Surface Disturbance Mapping protocol and are described here:

- [Disturbance mapping procedure](https://docs.google.com/document/d/1ky6wQpCng_xjHoXmQWgfAO8EDmQNhslJ0nRq3b5YgwQ/edit?usp=sharing)


# code folder

gen_fda_data.R

- generates a geopackage for a selected FDA that consists of various disturbance and other datasets

gen_fda_hydro.R

- generates a geopackage for a selected FDA that consists of streams, lakes, rivers, and FDA boundary

merge_disturbances.R

- merges existing anthropogenic disturbance (from YG) with newly digitized disturbances


# data folder

The following regional disturbance datasets are listed below. The key layers are the areal and linear features ("Areal_Features", "Areal_Features+", "Linear_Features", "Linear_Features+"). Both versions of the disturbance features include YG surface disturbance data; a "+" suffix indicates that the data also include  features that were digitized by the BEACONs project and subsequently merged with the YG data.

## fda_xxxx.gpkg

The "xxxx" portion of the name refers to the unique alphanumeric id of the FDA e.g., 10AB or 09EA.

### Layers

<pre>
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
</pre>

### Attributes for areal and linear features

<pre>
CODE_POLY / CODE_LINE
TYPE_INDUSTRY
TYPE_DISTURBANCE
DIST_YEAR
SCALE
CREATED_BY
DIGZ_DATE
IMAGE_NAME
IMAGE_DATE
RESOLUTION
SENSOR
FLAG
VHR_ASSIST
NOTES
geometry
Area_ha / Length_km
</pre>