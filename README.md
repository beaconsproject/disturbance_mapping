# Regional Disturbance Mapping

# Introduction

February 13, 2025

The Regional Disturbance Mapping project provides access to data, methods and tools to develop and validate regional-scale disturbance maps that can be used for conservation and land use planning.

The primary components of the website are:

- A growing list of regional and national disturbance and ancillary datasets
- A procedures manual for digitizing linear and areal surface disturbances from satellite imagery
- A detailed workflow for conducting a mapping project in a study area located in the Yukon and/or BC
- A Shiny app for validating disturbance database attributes
- Additional resources relevant to regional disturbance mapping

# Disturbance mapping paper

- [Manuscript - in prep (private)] (https://docs.google.com/document/d/1odYaCYmW05E3kvzcx0dSBb5RGP6l5cOvKXGkJjK26jQ/edit?pli=1)

# Disturbance datasets

A number of existing disturbance and related datasets exist in both Yukon and British Columbia. We are currently compiling a list of the most relevant datasets:

- [Disturbance datasets lists](https://docs.google.com/spreadsheets/d/1jrF-9GxjVUxCpmETts-CGrAiqsv6Wm407Qsez8uCN8k/edit#gid=506214747)

Downloadable datasets (public):
- [bp_datasets.gpkg](https://drive.google.com/file/d/10864Smj6nCOB12c6B2F0bjqk3VCgshJV/view?usp=sharing) - core datasets for use with `geopackage_creator` app. Coverage includes all of Yukon and portions of BC and NT.
- [projected.gpkg](https://drive.google.com/file/d/10CYexK4VIPRb2iuqB_n8o7f9hlvVm_YJ/view?usp=sharing) - quartz and placer mining claims in the Yukon
- [species.gpkg](https://drive.google.com/file/d/1-yosX3t0I4JJ8vLVit4vuUwKFhLib-Ut/view?usp=sharing) - various species ranges in the Yukon

# Disturbance mapping manual

The primary objective of the project is to fill gaps in the coverage of disturbances using high resolution remote sensing imagery. The procedures to do so were adapted from the YG Government Surface Disturbance Mapping protocol and are described here:

- [Go to manual](https://github.com/beaconsproject/disturbance_mapping/tree/master/procedures)

The original Yukon Government's manuals can be viewed here:

- [Summary document](https://drive.google.com/file/d/1LUja-JRxFI0Q2jeqqi8j-X0G0QRrzGEI/view?usp=sharing)
- [Standards and guidelines](https://drive.google.com/file/d/1mwLDDqO4COUW-2n3l09A_Q9fu04yLp71/view?usp=sharing)
- [Feature interpretation key](https://drive.google.com/file/d/1SpcR-r_lQn_urERG8_CUl7oRQRJUxOri/view?usp=sharing)


# Disturbance validation tool

The Disturbance Validation app is a Shiny app that enables users to i) interactively examine linear and areal surface disturbance features along with several satellite imagery sources, ii) validate industry and disturbance type attributes, and iii) randomly select individual features and their associated attributes. This permits alternative digitizers or other users to quickly look at the digitized features and their assigned attributes, and visually compare them to more than one high resolution imagery source. Three satellite images are available for viewing: Esri WorldImagery, Google Imagery, and SPOT Imagery for circa 2021.

1. Install R (download from r-project.org and follow instructions)
2. Install the following additional packages:

>install.packages(c("markdown","sf","leaflet","leaflet.esri","dplyr","shinydashboard","DT","summarytools"))

3. Start the Shiny app:

>shiny::runGitHub(repo="beaconsproject/disturbance_mapping", subdir="validation")

