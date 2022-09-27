# Regional disturbance mapping

The goal of the regional disturbance mapping project is to develop and validate a regional-scale disturbance map for a pilot planning region in southeast Yukon and northwest BC that can be used for conservation and land use planning. Our specific objectives are to:

- Develop regional disturbance maps using existing datasets
- Identify spatial and temporal gaps in disturbance maps
- Fill gaps in coverage using remote sensing imagery (digitizing)
- Validate and update disturbance maps using high resolution remote sensing and field based data
- Develop value-added products such as footprint/intactness and resistance/permeability maps


## Disturbance datasets

A number of existing disturbance and related existing datasets exist in both Yukon and British Columbia. We are currently compiling a list of the most relevant datasets:

- Yukon datasets
- BC datasets


## Protocol for manual disturbance mapping

The third objective of the Regional Disturbance Mapping project is to fill gaps in the coverage of disturbances using high resolution remote sensing imagery. The procedures to do so were adapted from the YG Government Surface Disturbance Mapping protocol and are described here:

- [Disturbance mapping procedure](https://docs.google.com/document/d/1ky6wQpCng_xjHoXmQWgfAO8EDmQNhslJ0nRq3b5YgwQ/edit?usp=sharing)


## Regional footprint/intactness mapping app

The shiny app enables regional conservation planners to explore the effects of changing assumptions about the effects of disturbances (e.g., buffers of influence) on resulting human footprint and intactness maps. To run the app from a local machine:

  1. Install R (download from r-project.org and follow instructions)
  2. Install the following additional packages:

    install.packages(c("sf","dplyr","leaflet","shiny","shinydashboard"))

  3. Start the Shiny app:

    shiny::runGitHub("beaconsproject/dc-mapping/apps/footprint.R")


## Regional resistance/permeability mapping app

TO DO: Develop shiny app will enable regional conservation planners to explore the effects of changing assumptions about the effects of disturbances (e.g., buffers of influence) on resulting resistance or permeability surfaces prior to their use in connectivity analysis and mapping. To run the app from a local machine:
