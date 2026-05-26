### Disturbance Validation

The Disturbance Validation app is a Shiny app that enables users to i) interactively examine linear and areal surface disturbance features along with high resolution ESRI and Google satellite imagery, ii) edit linear and areal disturbance attribute values if needed, and iii) validate industry and disturbance type attribute values. This permits users or reviewers to quickly look at the digitized features and their assigned attributes, ensure that only permitted values are used for disturbance types, and edit them if necessary.

<center><img src="app.png" width="600"></center>

<hr>

#### Features

| Feature | Description |
|---------|-------------|
| Map view | Leaflet map with ESRI Imagery / Topo / Gray basemaps and a layer-toggle control |
| Table view | Tables displaying the values of the Linear and Areal disturbance features |
| Scale bar | Dynamic `1:X` scale indicator in the map header |
| Grid generator | Create an *n × n* km grid (1–25 km) intersecting the study area |
| Click to inspect | Click any linear or areal feature to see its attributes in the side cards |
| Editable attributes | Modify any field value directly in the attribute cards |
| Save edits | *Save Attribute Edits* commits changes back to the in-memory layers |
| Export | *Export as GeoPackage* writes all layers (including the grid if created) to a new `.gpkg`, then a download button appears |

<hr>

#### Structure

The Disturbance Validation app consists of 3 sections:

**Introduction**

This section includes this overview page plus a tab describing all permitted industry and disturbance types.

**View Features**

**Validate attributes**

This sections allows the user to view a summary of the linear and areal disturbance attributes and validate their values. There are three steps:

1. Upload data: Upload a geopackage (".gpkg") containing study area boundary, linear disturbances, and areal disturbances (see notes below). 
2. Select layer names from the 3 dropdown boxes.
3. Validate results: results will be displayed in the 4 tabs on the right.

<hr>

#### Required layers and attributes
  
**Required layers**

- studyarea : A single polygon outlining the boundary of the study area e.g., a watershed or ecoregion or any other user-defined area.
- linear_disturbance : Linear anthropogenic surface disturbance features. Available from: https://map-data.service.yukon.ca/geoyukon/Environmental_Monitoring/
- areal_disturbance : Areal (polygonal) anthropogenic surface disturbance features. Available from: https://map-data.service.yukon.ca/geoyukon/Environmental_Monitoring/

**Required attributes**

The studyarea layer does not require any particular attributes.

The linear_disturbance layer must include the following attributes:
    
- TYPE_INDUSTRY : a text attribute describing industry type e.g., Mining, Transportation
- TYPE_DISTURBANCE : a text attribute describing disturbance type (nested within industry type) e.g., Survey / Cutline, Access Road
  
The areal_disturbance layer must include the following attributes:
    
- TYPE_INDUSTRY : a text attribute describing industry type e.g., Mining, Transportation
- TYPE_DISTURBANCE : a text attribute describing disturbance type (nested within industry type) e.g., Drill Pad, Clearing
