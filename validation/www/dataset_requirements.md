### Required Layers and Attributes
  
This page describes the required map layers and attributes that are used by the *Disturbance Validation* app. Additional resources are available on Github at: https://github.com/beaconsproject/disturbance_validation/tree/main/www
  
<hr>

### Required layers

The Geopackage must contain the following three layers

- **studyarea** : A single polygon outlining the boundary of the study area e.g., a watershed or ecoregion or any other user-defined area.
- **linear_disturbance** : Linear anthropogenic surface disturbance features. Available from: https://map-data.service.yukon.ca/geoyukon/Environmental_Monitoring/
- **areal_disturbance** : Areal (polygonal) anthropogenic surface disturbance features. Available from: https://map-data.service.yukon.ca/geoyukon/Environmental_Monitoring/

To **Validate Attributes** a .csv file of approved Industry and Disturbance types is required. A template is available from: https://github.com/beaconsproject/disturbance_validation/blob/main/www/yg_industry_disturbance_types.csv

<hr>

### Required attributes

The **studyarea** layer does not require any particular attributes.

The **linear_disturbance** layer must include the following attributes:
    
- TYPE_INDUSTRY : a text attribute describing industry type e.g., Mining, Transportation
- TYPE_DISTURBANCE : a text attribute describing disturbance type (nested within industry type) e.g., Survey / Cutline, Access Road
  
The **areal_disturbance** layer must include the following attributes:
    
- TYPE_INDUSTRY : a text attribute describing industry type e.g., Mining, Transportation
- TYPE_DISTURBANCE : a text attribute describing disturbance type (nested within industry type) e.g., Drill Pad, Clearing

<hr>

### Random features #is this header relevant?

This section allows users to randomly select a feature to view it along with its attributes.

The areal disturbance layer should include the following attributes:
  - REF_ID
  - TYPE_INDUSTRY
  - TYPE_DISTURBANCE
  - CREATED_BY
  - IMAGE_DATA
  - Area_ha

The linear disturbance layer should include the following attributes:
  - REF_ID
  - TYPE_INDUSTRY
  - TYPE_DISTURBANCE
  - CREATED_BY
  - IMAGE_DATA
  - Length_km
