# Regional Disturbance Mapping

## Introduction

January 14, 2026

The Regional Disturbance Mapping project provides access to data, methods and tools to develop and validate regional-scale disturbance maps that can be used for conservation and land use planning.

The primary components of the website are:

- A growing list of regional and national disturbance and ancillary datasets
- A procedures manual for digitizing linear and areal surface disturbances from satellite imagery
- A detailed workflow for conducting a mapping project in a study area located in the Yukon and/or BC
- A Shiny app for validating disturbance database attributes
- Additional resources relevant to regional disturbance mapping

## Disturbance mapping manual

The primary objective of the project is to fill gaps in the coverage of disturbances using high resolution remote sensing imagery. The procedures to do so were adapted from the YG Government Surface Disturbance Mapping protocol and are described here:

- [Go to manual (PDF version 2024-08-20)](https://github.com/beaconsproject/disturbance_mapping/blob/master/assets/BP_SurfaceDisturbance_Mapping_Procedures_2024-08-20.pdf)
- [Go to manual (Google docs version - password protected)](https://docs.google.com/document/d/1pVEeJe09dDMEV8KVDPm5VlvCeTs8LtK8vEzI-lGqiC8/edit?tab=t.0)

The original Yukon Government's manuals can be viewed here:

- [Summary document](https://drive.google.com/file/d/1LUja-JRxFI0Q2jeqqi8j-X0G0QRrzGEI/view?usp=sharing)
- [Standards and guidelines](https://drive.google.com/file/d/1mwLDDqO4COUW-2n3l09A_Q9fu04yLp71/view?usp=sharing)
- [Feature interpretation key](https://drive.google.com/file/d/1SpcR-r_lQn_urERG8_CUl7oRQRJUxOri/view?usp=sharing)


## QGIS mapping template

We've provided a [QGIS project template](template) that includes two empty map layers for digitizing areal and linear disturbances. The layers include all of the required attributes. The project template also includes links to Yukon SPOT imagery as well as ESRI imagery to help with the digitization process.

## Disturbance datasets

A number of existing disturbance and related datasets exist in both Yukon and British Columbia. We are currently compiling a list of the most relevant datasets:

- [Disturbance datasets lists](https://docs.google.com/spreadsheets/d/1jrF-9GxjVUxCpmETts-CGrAiqsv6Wm407Qsez8uCN8k/edit#gid=506214747)

Downloadable datasets (please email vernier@ualberta.ca for access):
- [bp_datasets.gpkg](https://drive.google.com/file/d/1-b3v0q-zI8Wf1URShyfxVyGxtdZOYGWF/view?usp=sharing) - core datasets for use with `geopackage_creator` app. Coverage includes all of Yukon and portions of BC and NT.
- [projected.gpkg](https://drive.google.com/file/d/1elO7hPsHipDAnMMLg8xLXkrum1kKMuMa/view?usp=sharing) - quartz and placer mining claims in the Yukon
- [species.gpkg](https://drive.google.com/file/d/1-yosX3t0I4JJ8vLVit4vuUwKFhLib-Ut/view?usp=sharing) - various species ranges in the Yukon

## Disturbance validation tool

The [Disturbance Validation](validation) app is a Shiny app that enables users to interactively examine linear and areal surface disturbance features and validate industry and disturbance type attributes.

## Disturbance mapping paper

- [Manuscript - in prep (private)](https://docs.google.com/document/d/1odYaCYmW05E3kvzcx0dSBb5RGP6l5cOvKXGkJjK26jQ/edit?pli=1)

