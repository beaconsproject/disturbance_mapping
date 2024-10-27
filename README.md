# Regional Disturbance Mapping

# Introduction

October 25, 2024

The Regional Disturbance Mapping project provides access to data, methods and tools to develop and validate regional-scale disturbance maps that can be used for conservation and land use planning.

The primary components of the website are:

- A growing list of regional and national disturbance and ancillary datasets
- A procedures manual for digitizing linear and areal surface disturbances from satellite imagery
- A detailed workflow for conducting a mapping project in a study area located in the Yukon and/or BC
- A Shiny app for validating disturbance database attributes
- Additional resources relevant to regional disturbance mapping


# Disturbance datasets

A number of existing disturbance and related datasets exist in both Yukon and British Columbia. We are currently compiling a list of the most relevant datasets:

- [Disturbance datasets lists](https://docs.google.com/spreadsheets/d/1jrF-9GxjVUxCpmETts-CGrAiqsv6Wm407Qsez8uCN8k/edit#gid=506214747)

Downloadable datasets (public):
- [bp_datasets.gpkg](https://drive.google.com/file/d/10864Smj6nCOB12c6B2F0bjqk3VCgshJV/view?usp=sharing) - core datasets for use with `geopackage_creator` app. Coverage includes all of Yukon and portions of BC and NT.
- [projected.gpkg](https://drive.google.com/file/d/10CYexK4VIPRb2iuqB_n8o7f9hlvVm_YJ/view?usp=sharing) - quartz and placer mining claims in the Yukon
- [species.gpkg](https://drive.google.com/file/d/1-yosX3t0I4JJ8vLVit4vuUwKFhLib-Ut/view?usp=sharing) - various species ranges in the Yukon

# Disturbance mapping manual

The primary objective of the project is to fill gaps in the coverage of disturbances using high resolution remote sensing imagery. The procedures to do so were adapted from the YG Government Surface Disturbance Mapping protocol and are described here:

- [Digitizing manual](https://docs.google.com/document/d/1pVEeJe09dDMEV8KVDPm5VlvCeTs8LtK8vEzI-lGqiC8/edit)
- [Digitizing status](https://docs.google.com/spreadsheets/d/14WEbqjB_3xVwuxKis1RJtjs9PfN7rkKLnOwQ8hq7qoU/edit#gid=0)

The original Yukon Government's manuals can be viewed here:

- [Summary document](https://drive.google.com/file/d/1LUja-JRxFI0Q2jeqqi8j-X0G0QRrzGEI/view?usp=sharing)
- [Standards and guidelines](https://drive.google.com/file/d/1mwLDDqO4COUW-2n3l09A_Q9fu04yLp71/view?usp=sharing)
- [Feature interpretation key](https://drive.google.com/file/d/1SpcR-r_lQn_urERG8_CUl7oRQRJUxOri/view?usp=sharing)


# Disturbance validation tool

The Disturbance Validation app is a Shiny app that enables users to i) interactively examine linear and areal surface disturbance features along with several satellite imagery sources, ii) validate industry and disturbance type attributes, and iii) randomly select individual features and their associated attributes. This permits alternative digitizers or other users to quickly look at the digitized features and their assigned attributes, and visually compare them to more than one high resolution imagery source. Three satellite images are available for viewing: Esri WorldImagery, Google Imagery, and SPOT Imagery for circa 2021.

The `disturbance validation` app can be run [online](https://beaconsproject.shinyapps.io/disturbance_validation) or from a local machine using the following steps (note, the first 2 steps only need to be run once):

1. Install R (download from r-project.org and follow instructions)
2. Install the following additional packages:

>install.packages(c("sf","leaflet","dplyr","shinydashboard",DT))

3. Start the Shiny app:

>shiny::runGitHub(repo="beaconsproject/disturbance", subdir="validation")

