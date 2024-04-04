# Introduction

Updated: April 4, 2024

The Regional Disturbance Mapping project provides access to data, methods and tools to develop and validate regional-scale disturbance maps that can be used for conservation and land use planning.

The primary components of the website are:

- A growing list of regional and national disturbance and ancillary datasets
- A procedures manual for digitizing linear and areal surface disturbances from satellite imagery
- A detailed workflow for conducting a mapping project in a study area located in the Yukon and/or BC
- A Shiny app for validating disturbance database attributes
- Additional resources relevant to regional disturbance mapping


# Disturbance datasets

A number of existing disturbance and related datasets exist in both Yukon and British Columbia. We are currently compiling a list of the most relevant datasets:

- [Disturbance datasets](https://docs.google.com/spreadsheets/d/1jrF-9GxjVUxCpmETts-CGrAiqsv6Wm407Qsez8uCN8k/edit#gid=506214747)


# Disturbance mapping manual

The primary objective of the project is to fill gaps in the coverage of disturbances using high resolution remote sensing imagery. The procedures to do so were adapted from the YG Government Surface Disturbance Mapping protocol and are described here:

- [Digitizing manual](https://docs.google.com/document/d/1pVEeJe09dDMEV8KVDPm5VlvCeTs8LtK8vEzI-lGqiC8/edit)
- [Digitizing status](https://docs.google.com/spreadsheets/d/14WEbqjB_3xVwuxKis1RJtjs9PfN7rkKLnOwQ8hq7qoU/edit#gid=0)

The original Yukon Government's manuals can be viewed here:

- [Summary document](https://drive.google.com/file/d/1LUja-JRxFI0Q2jeqqi8j-X0G0QRrzGEI/view?usp=sharing)
- [Standards and guidelines](https://drive.google.com/file/d/1mwLDDqO4COUW-2n3l09A_Q9fu04yLp71/view?usp=sharing)
- [Feature interpretation key](https://drive.google.com/file/d/1SpcR-r_lQn_urERG8_CUl7oRQRJUxOri/view?usp=sharing)


# Disturbance validation tool

The `disturbance validation` app can be run by pulling this repo or from a local machine using the following steps (note, the first 2 steps only need to be run once):

1. Install R (download from r-project.org and follow instructions)
2. Install the following additional packages:

  install.packages(c("sf","leaflet","dplyr","shinydashboard",DT))

3. Start the Shiny app:

  shiny::runGitHub("beaconsproject/disturbance_validation")


# Project workflow

The following steps describe the disturbance mapping workflow for one area of interest (AOI), from preparing a data package for digitizing to merging the newly digitized features with existing disturbance features. All of the steps can be completed using QGIS and are appropriate for projects that are conducted with Yukon and/or BC. Where procedures differ by jurisdiction, both Yukon and BC variations are described. A set of scripts have been written to automate parts of the workflow as much as possible (e.g., creating a data package).

## 1. Before digitizing

Prior to digitizing it is necessary to 1) create a QGIS project, 2) prepare a data package contain all necessary map layers for an area of interest (AOI), 3) add several web services to the QGIS project, and 4) create a worksheet containing a list of grid cells that will be used to track progress. An AOI can be a watershed (e.g., FDA), an ecoregion, a caribou range, or any other polygon defining a study (planning) area.

**1.1 Create QGIS project**

The first step is to create a new GIS project called "Digitizing_project.qgz" and save it in a new directory where all project files will be stored. This can simply be done by opening QGIS, creating a new project, and saving it. All map layers that are created in the next section can be added and organized within the QGIS project.

**1.2 Prepare data package**

The second step is to prepare several map layers and save them in a new geopackage file. This can be done manually (with the exception of creating a nested grid) or using the accompanying R script (recommended). 

Manual approach (QGIS):

1. Create a new geopackage file and call it "Data_package.gpkg". This will be used to save each layer that is created in the steps described below. Make sure to save the FDA and all other layers in the desired CRS (e.g., 3578 in the Yukon).
2. Select the AOI of interest and save it as a layer in a new geopackage.
3. Select all intersecting NTS 50k grids to the AOI.
4. Create 3x3 and 9x9 nested grids using "gen_grids.R" script. Clip or select each to the AOI.
5. Clip or select YG linear and areal disturbance layers that intersect AOI and save.
6. Clip forest fire polygons to AOI and save.
7. Clip placer and quartz mining claims and save.
8. Clip additional layers, as needed, to assist in digitizing e.g., human_access_2010.

Scripting approach (R):

- Open the "gen_nested_grids.R" script, modify parameters at the top of the script to specify the location of the NTS grid, and run the script to create 3x3 and 9x9 grids that are nested within the NTS grids.
- Open the "gen_data_package.R" script and modify the parameters at the top of the script to specify the location of the AOI and all additional datasets.
- Run the script and verify output layers in the data package using QGIS.

1.3 Add web services

The third step is to add the following web services to the QGIS project:

- GeoYukon SPOT mosaic: https://map-data.service.yukon.ca/geoyukon/ 
- Google Imagery: https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z} 
- ESRI Imagery with date information: https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer 

**1.4 Prepare google sheet to track digitizing status**

The fourth step is to open the digitizing status Google sheet and:

- Create a new worksheet giving it a name that reflects the AOI e.g., FDA_10AB
- Copy the header row from another worksheet
- Copy the NTS 50k grid IDs to the first column

## 2. While digitizing

The main section of this document provides detailed instructions on digitizing linear and areal disturbances. This comprises two main tasks:

1. Digitize linear and areal anthropogenic disturbance features following the procedures described in the procedures manual.
2. Update the digitizing status worksheet, ensuring all attributes are filled (including changing the status field from 0 to 1 once grid square has been digitized.

## 3. After digitizing

There are three broad steps to complete at the completion of a digitizing project: 1) update the digitizing status map layer to update the status of newly digitized cells, 2) merge the newly digitized layers with the existing YG datasets for the AOI, 3) validate the merged dataset, and 4) update the master surface disturbance database. 

**3.1 Update grid_100k layer with "status" attribute**

- Input: bp_digitizing_status.gsheet, bp_digitizing_grid.gpkg
- Output: bp_digitizing_grid.gpkg
- Script: get_status.R - read the worksheets and update the Grid_100k layer

**3.2 Merge BP and YG datasets**

For each project (FDA or caribou range):

1. SD_Line and SD_Poly layers: Drop rows where DATABASE=="Retired"
2. Merge SD_Line and BP_Line; merge SD_Poly and BP_Poly

**3.3 Validate the merged dataset**

- Attribute validation: Use the validation tool (Shiny app) to validate the linear and areal disturbance attributes.
- Spatial validation

**3.4 Update master surface disturbance database**

Merge linear and areal disturbance for all project-level datasets

1. Clip latest YG surface disturbances to combined SE Yukon project area
2. For each project area (AOI):
    - Drop YG features that have been flagged as "Retired" in the project layers
    - Add all newly digitized features to the database
