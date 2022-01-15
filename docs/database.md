# Spatial Database

## Develop spatial database

### Identify and acquire existing disturbance datasets

Activities:

- Define study boundary for spatial database (KDTT? Y2Y northern region?)
- Identify existing disturbance datasets from websites, indigenous partners, government, NGOs
- Build a list (spreadsheet matrix) of available datasets and their characteristiscs; group datasets into disturbance categories (e.g., roads, oil and gas, mining, forestry)
- Acquire national and regional datasets where they are available; if datasets are not available, contact owners. Some sources include:
    - Existing national datasets: Canada HFP (2019), seismic lines (Lucy), roads (Lucy)
    - Existing regional datasets:
        - DataBC - [https://data.gov.bc](https://data.gov.bc/)
        - GeoYukon - [https://yukon.ca/en/geoyukon](https://yukon.ca/en/geoyukon)
- Upload all original datasets to University of Alberta server
- Describe the characteristics of each dataset e.g., coverage, year, resolution, input data sources

Products:

- Spreadsheet with list of available disturbance datasets along with characteristics and contacts
- All original datasets along with record of date of acquisition, website or ftp site, contact person

### Develop a spatial database with common extent and projection

Activities:

- Prepare database with common spatial extent and projection
    - Clip all datasets to study boundary and project to regional projection (Yukon or BC Albers?)
    - Automate and document the process of preparing each dataset using R or Python
    - Where it makes sense, combine similar datasets into one disturbance type e.g., roads from different sources or harvest data from different tenure holders
- Upload derived datasets to University of Alberta server
- Save all code, metadata, and documentation to GitHub

Products:

- Spatial database that includes:
    - All individual datasets clipped to the study boundary and reprojected
    - All combined datasets
- Code and documentation to enable replication

### Identify spatial and temporal gaps in coverage

Activities:

- Evaluate completeness of datasets for each identified disturbance type
    - Identify gaps in spatial and temporal coverage using a time x space x resolution matrix

Products:

- Map and table describing spatial and temporal coverage of datasets and, by extension, gaps

2. Develop disturbance maps (Mar 2022 – May 2022)
