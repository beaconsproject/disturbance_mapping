# Regional disturbance and intactness mapping

## Mapping Workflow

### Create disturbance dataset

#### Assemble existing datasets

- Disturbance datasets (Yukon) - Link to Google sheet
- Disturbance datasets (BC) - Link to Google sheet

#### Create preliminary database

- Using R to combine disparate datasets into one geopackage with common extent and reference system.

#### Identify gaps in coverage

- Identify spatial gaps
- Identify temporal gaps

#### Prioritize areas to digitize

#### Digitize disturbances

- Disturbance mapping procedure manual - Link to Google document

#### Identify year of origin of disturbances

Automate the identification of the year of origin of disturbances:

 1. Start with 1984-2019 landcover dataset
 2. Use GEE dNBR algorithm for those not done in step 1
 3. Use high resolution imagery of various sources and manually identify missing features
 4. Identify remaining areas and design field work

#### Validate disturbance database


## Workflow

### Step 1: Prepare existing disturbance map

  - Assemble existing datasets
  - Identify spatial and temporal gaps
Products:
  - datset links
  - rmd examples

### Step 2: Fill gaps in existing disturbance map

Procedure:
  - Digitize anthropogenic features using SPOT imagery (1.5m)
  - Validate linework and attributes
  - Merge with existing disturbance map
  - Identify year of origin of disturbances
  - Update to current year

Products:
  - Marc's doc
  - Merged cumulative disturbance dataset (points, lines and polygons)
  - Temporal map

### Step 3: Validation

  - Spatial (app)
  - Temporal
  - Attribute

### Step 4: Merge

  - Merge datasets
  - Prepare dataset documentaion

### Step 5: Origin of disturbance

  - GEE automation

### Step 6: Conservation applications

  - Intactness
  - 

## Case studies


