# BEACONs Disturbance Mapper

A Shiny dashboard for visualising and editing disturbance layers stored in a GeoPackage.

---

## Requirements

Install all required packages once:

```r
install.packages(c(
  "shiny",
  "bslib",
  "leaflet",
  "leaflet.extras",
  "sf",
  "dplyr",
  "DT",
  "htmltools",
  "htmlwidgets"
))
```

> **Note:** `sf` requires system libraries (`GDAL`, `GEOS`, `PROJ`).  
> On Ubuntu/Debian: `sudo apt-get install libgdal-dev libgeos-dev libproj-dev`  
> On macOS (Homebrew): `brew install gdal geos proj`

---

## GeoPackage structure

The uploaded `.gpkg` must contain exactly these four layers:

| Layer name            | Geometry type | Display name         |
|-----------------------|---------------|----------------------|
| `studyarea`           | Polygon       | Study area           |
| `linear_disturbance`  | LineString    | Linear disturbances  |
| `areal_disturbance`   | Polygon       | Areal disturbances   |
| `fires`               | Polygon       | Fires                |

All layers may be in any CRS; the app re-projects to WGS 84 (EPSG 4326) for display.  
Invalid geometries are automatically repaired with `sf::st_make_valid()`.

---

## Features

| Feature | Description |
|---------|-------------|
| **Map view** | Leaflet map with ESRI Imagery / Topo / Gray basemaps and a layer-toggle control |
| **Scale bar** | Dynamic `1:X` scale indicator in the map header |
| **Grid generator** | Create an *n × n* km grid (1–25 km) intersecting the study area |
| **Click to inspect** | Click any linear or areal feature to see its attributes in the side cards |
| **Editable attributes** | Modify any field value directly in the attribute cards |
| **Save edits** | *Save Attribute Edits* commits changes back to the in-memory layers |
| **Export** | *Export as GeoPackage* writes all layers (including the grid if created) to a new `.gpkg`, then a download button appears |

---

## Running the app

```r
shiny::runApp("app.R")
```

Or from the same directory:

```r
source("app.R")
```

---

## Layout

```
┌──────────────────────────────────────────────────────────────┐
│  BEACONs Disturbance Mapper                                  │
├─────────────┬────────────────────────────┬───────────────────┤
│  Sidebar    │  Map card  (~70%)          │  Linear card      │
│             │  ┌──────────────────────┐  │  (attributes of   │
│  • Upload   │  │ Tab: Map             │  │   clicked line)   │
│  • Grid     │  │ Tab: Linear attrs    │  ├───────────────────┤
│  • Save     │  │ Tab: Areal attrs     │  │  Areal card       │
│             │  └──────────────────────┘  │  (attributes of   │
│             │                            │   clicked poly)   │
└─────────────┴────────────────────────────┴───────────────────┘
```
