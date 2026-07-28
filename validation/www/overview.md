## Disturbance Validation

The Disturbance Validation app is a Shiny app that enables users to i) interactively examine linear and areal surface disturbance features along with several satellite imagery sources, ii) validate industry and disturbance type attributes, and iii) randomly select individual features and their associated attributes. This permits alternative digitizers or other users to quickly look at the digitized features and their assigned attributes, and visually compare them to more than one high resolution imagery source. Three satellite images are available for viewing: Esri WorldImagery, Google Imagery, and SPOT Imagery for circa 2021.

<center><img src="app.jpg" width="600"></center>

The Disturbance Validation app consists of Three sections:

### Introduction

This section includes this overview page plus a tab describing all permitted industry and disturbance types. The Dataset requirements tab provides information on layer requirements for running the app.

### View Features

This section allows the user to view a map of digitized disturbance features over satellite imagery, and select features on the map to view and edit their attributes. 

The Linear features and Areal features tabs allow the user to view the attribute table for all linear or areal (polygonal) features in the dataset.


### Validate attributes

This section allows the user to view a summary of linear and areal disturbance attributes, validate their values, and identify errors.


### User Guide

Follow these steps to validate digitized disturbances:

1. Upload data: Upload a geopackage (".gpkg") containing a study area boundary, linear disturbances, and areal disturbances (see dataset requirements). 
2. Select layer names from the 3 dropdown boxes and click **Map features**.
3. View results: results will be displayed in the 4 tabs on the right.
4. Under the **Validate Attributes** section, upload a .csv of approved attributes (the approved combination of Industry and Disturbance types) and click **Validate attributes**. 
- A .csv of approved attributes is available here: https://github.com/beaconsproject/disturbance_validation/blob/main/www/yg_industry_disturbance_types.csv
- A summary of the database, errors, and permitted values based on the .csv will be presented in the four tabs to the right
- To edit the attributes of a feature, the user can: 
  - Search for the feature ID under the search tab on the left or view and flip through the dataset attribute table
  - Select a feature in the mapview and edit its attributes in the feature table on the right. 
