# Disturbance Mapping

Conserving wilderness and intact areas is a top priority for conservation in the boreal region, and cumulative disturbance (or human footprint) maps are a practical way to identify such areas. However, available global assessments of wilderness and intact areas are generally too coarse or exclude local disturbance types (Vernier et al. 2021, Preprint), and consequently are not very useful for regional conservation and land use decisions. Our overall goal is to develop and validate a regional scale cumulative disturbance map for a pilot planning region in southeast Yukon and northwest BC that could be used for conservation and land use planning. Specifically, our objectives are to:

- Develop individual and cumulative disturbance maps
- Develop value-added products such as human footprint and intactness maps
- Validate and enhance map products using remote sensing and field based data

## Develop disturbance maps

### Develop individual disturbance type maps

Activities:

- Some disturbance types may not need further processing; others will need to be combined spatially, for example when combining data from Yukon and BC or between tenure holders
- Combine similar disturbance type maps
- Upload combined disturbance type maps to University of Alberta server

Products:

- Individual disturbance maps comprising individual or multiple datasets
- Code and documentation to enable replication

### Develop cumulative disturbance maps

Activities:

- Review methods for combining individual disturbance maps in cumulative disturbances maps
    - Examples include: ABMI, BEAD
- Develop a detailed algorithm for combining individual datasets into:
    - Cumulative map of linear disturbances (vector)
    - Cumulative map of polygonal disturbances (vector)
- Combine linear and polygonal disturbance maps into a single cumulative disturbance map
    - Add a small buffer around linear disturbances
    - Create a raster version of the cumulative disturbance map
- Save all code, metadata, and documentation to GitHub
- Upload cumulative disturbance maps to University of Alberta server

Products

- Database that includes:
    - Vector linear and polygonal disturbances
    - Combined vector and raster cumulative disturbance maps
    - Code and documentation to enable replication

## Develop value added products

The focus of this component is to develop value-added products from the individual and cumulative map products. Initially, we will focus on two: a regional scale human footprint map and a regional scale landscape intactness map. More than one map of each type can be developed depending on assumptions e.g., the size of zones of influence buffers.

### Create human footprint maps (optional)

The human footprint map takes individual disturbance layers and applies buffers and weights to create a final map showing human pressures ranging from 0 to some maximum which depends on the area and the input maps.

- Apply the human footprint methodology developed by Sanderson (1996) and revised by Venter et al. (2016) to create a regional human footprint map
    - Apply and code original method
    - Develop a tool that enables users to modify the input parameters used to create the human footprint map i.e., buffer sizes and weights (pressure scores)

Products:

- Regional footprint maps using original and modified methods
- Tool enabling user to create their own human footprint map

### Create intactness maps

Intactness maps can be created from i) the cumulative disturbance maps i.e., areas with no disturbances, ii) the cumulative disturbance map with human influence buffers added, or iii) the human footprint map. The minimum size (and shape) of intact areas can also be specified as an additional parameter.

Activities:

- Develop code to create custom intactness map based on user defined criteria for buffer sizes (if any) and weights (if any)

Products:

- Example intactness map(s)
- Tool for creating intactness map(s) from input individual disturbance maps or cumulative disturbance map


## Validate and enhance map products

The focus of this component is on developing and implementing a strategy for validating disturbance and intactness maps.

### Fill in gaps in coverage

Activities:

- Evaluate completeness of datasets for each identified disturbance type.
    - Identify gaps in spatial and temporal coverage
    - Assess whether gaps can be filled with detailed disturbance mapping
        - Mapping using recent high resolution satellite imagery
        - Digitizing from recent air photos
        - Drone footage
- Fill in gaps in spatial and temporal coverage (long-term objective)
    - Prioritize gaps
    - Identify collaborators (Liard First Nation, citizen scientists, researchers) with requisite experience to validate and map disturbances
        - Interpret satellite imagery
        - Interpret (classify) and map (digitize) disturbances from air photos
    - Combine newly create maps with existing disturbance type maps (unless it's a unique disturbance map)
- Document procedures for mapping disturbances to fill in gaps

Products:

- Procedure manual (tutorial) for disturbance mapping using satellite imagery and air photos
- Disturbance maps for the gaps in coverage (stand alone and combined with existing maps)

### Remote-based validation

Activities:

- Use high-resolution satellite imagery to validate accuracy of final cumulative disturbance maps
- Design validation plan (Satellite-based)
    - Select validation data source (Google Earth Engine, ESRI World Imagery)
    - Evaluate different strategies (e.g., random, stratified random, systematic sampling) in terms of power and precison.
        - How many plots do we need to have a desired level of precision?
        - Define criteria for inclusion or rejection of individual plots.
    - Develop a standardized key to visually interpret the individual disturbances
    - Visually identify disturbances within 5,000, 1-km2 randomly located sample plots
        - Estimate type and area of disturbances
    - Quantify the level of agreement between the disturbance maps and the validation dataset (RMSE, Cohen's kappa)
    - Prepare document in tutorial format for validating disturbance maps using satellite imagery

Products:

- Statistical validation of disturbance maps
- Tutorial on validating disturbance maps using Google Earth Engine or similar framework

### Field-based validation

Activities:

- Design validation plan (field-based)
    - Evaluate different strategies (e.g., random, stratified random, systematic sampling) in terms of power and precision
    - Undertake field work based on validation plan

Products:

- Statistical validation of disturbance maps
- Field-based validation procedure manual

### Long term disturbance monitoring

The focus of this component is to develop a program and procedure for continuous remote and field monitoring of anthropogenic disturbances in the study region.

Activities:

- Collaborate with existing initiative involved in regional remote or field based monitoring term citizen-science e.g., Indigenous Guardians, ENGOs, etc.
- This component needs to be developed further
    - Using GEE and other data sources

Products:

- Monitoring plan
