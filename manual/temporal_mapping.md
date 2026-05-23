**Temporal Mapping of Anthropogenic Surface Disturbances:**   
**Recommended Procedures & User Guidelines**

The BEACONs Project | User Manual 

Last Updated: February, 2025

**Overview:** 

The purpose of this document is to provide a summary of the procedures utilized to generate temporal maps of anthropogenic surface disturbances, both linear and areal (polygonal), across areas of interest (AOIs) spanning the Yukon Territory’s northwest boreal regions. Datasets used to develop these methods were obtained from previous work conducted by the BEACONs project and were assiged disturbance dates based on their respective years of appearance using the Google Earth Pro ‘Timelapse’ tool. All GIS work was conducted in QGIS (open-source) in an effort to increase both the accessibility and applicability of the temporal mapping procedures outlined below. 

This document is divided into two sections: 

* ***Aging Surface Disturbances**:*  
  *  Detailed outline of the procedures used to digitize and date the appearance and expansion of anthropogenic surface disturbances through time.  
*  ***Project Tables**:*  
  *  Templates illustrating the format of the tables used to track work progress and relevant attribute information using Google Sheets & QGIS. 

**Aging Surface Disturbances** 

Surface disturbance layers containing existing linear and polygonal features (e.g., sd\_line & sd\_poly), should never be modified. 

Preparing the Project: 

* Create a new project in QGIS and prepare a geopackage containing all necessary linear  and areal disturbance layers for the study area. Ensure all project layers are saved in the same CRS (ESPG:  3578 – NAD83/Yukon Albers).   
*  Compress the surface disturbance layers (sd\_line and sd\_poly) into shapefiles (e.g.,  sd\_line.shp) containing the relevant attribute information.  

  o This includes, but is not limited to, information on a given layer's database, data  source, resolution, sensors, visibility, and user information.

*  Add Web Services: To the QGIS project, add base imagery from the following sources:   
  * GeoYukon SPOT mosaic, Google Imagery, and ESRI Imagery.    
* In Google Sheets, create a new worksheet within the ‘Dating Status’ Google Sheet, assigning it a name that reflects the study area (e.g., FDA\_10AB). This sheet will be used to track your progress as you progress through your datasets using the ‘Grid System Tracking’ method (see next bullet point). An example of a tracking worksheet is evidence Table 1\.  

Grid System Tracking: 

*  Using the grids contained within the project datapackage (1 km2 & 10 km2), track your progress starting from the top row, working left to right, before moving onto the next row.  
* Once reviewed and dated, a value of 1 is entered into the “STATUS” field of the ‘Dating Status’ (Table 1\) table to indicate that the cell has been reviewed. Upon completion of a thorough review, the status table, or can be noted separately and added to the table at the end of the session.

Scale of Capture:  

* Manual digitizing is completed at a scale of 1: 5,000 using ≤ 1.5m resolution satellite  imagery (e.g., SPOT 2020-21 mosaic or ESRI basemap imagery).    
* Temporal mapping of surface disturbances can be completed at any scale using available imagery sources (e.g., Google Earth Pro ‘Timelapse’, PLANET imagery, etc.). 

Manual Dating Methods: 

Linear & polygonal surface disturbances are dated using a four-category system developed to ensure any degree of uncertainty surrounding the appearance of a disturbance is adequately captured in the dataset. The four-category system is as follows:

* **YR\_DSTRBNC**: Date of occurrence for a given disturbance identified to the year.  
  * *Usage: High temporal resolution allows for a disturbance to be dated to the year of imagery in which it first appears, with no signs of the disturbance present in the imagery for the previous year.*   
* **YR\_VISIBLE**: Year of imagery when disturbance first becomes clearly identifiable:  
  * *Usage: When a degree of uncertainty exists surrounding the appearance of a disturbance on the landscape (e.g., poor resolution imagery in buffering years), the feature is dated to the earliest year in which it becomes clearly identifiable in the imagery*.  
* **YR\_IMAGERY**: Year of imagery used to digitize the feature.  
  * *Usage: In instances where “YR\_DSTRBNC” & “YR\_VISIBLE” fields are blank, this field is referred to as the earliest known date of disturbance. In most instances, disturbance is assumed to predate this.*  
* **YR\_EST**: Estimated year of disturbance & the value used to map features.   
  * *Usage: Based on information gathered, best estimate of the date of occurrence for a given disturbance on the landscape.*

• Aging Surfaces Disturbances (Google Earth Pro & Google Timelapse): 

o Method 1: Navigate to the AOI and Scroll through the available years in Google  Timelapse and Google Earth Pro to observe changes to the landscape. 

▪ Once the feature appears, return to the QGIS project to assign a date to the  DISTURBANCE\_YEAR attribute field. 

o Method 2: Import project shapefiles into Google Earth Pro, enabling users to digitize the timelapse imagery. The workflow for this process is as follows: 

▪ Import disturbance shapefile into Google Earth Pro (.klm file). 

▪ Digitize features as needed. 

▪ Convert back to shapefile using ESRI toolbox or QGIS equivalent. 

▪ Attributes must  be manually entered into QGIS. 

• Alternative Methods & Substitutions: 

o When significant temporal gaps exist in the available imagery for a particular AOI,  government records (e.g., YESAB registry, GeoYukon) can be used to assist in identifying the appearance of linear and polygonal surface disturbances. 

Disturbance Layer Digitizing (BP\_Line and BP\_poly): 

For disturbances known to have undergone polygonal growth through time, older polygons are digitized and subtracted from areasof the largest polygonal stage. This is completed using the ArcGIS ‘Erase’ tool, or the QGIS ‘Difference’ tool, generating non-overlapping polygons that are subsequently dated to their respective years of occurrence. Some features may end up being composed of many polygons, each with different  ‘YR\_DSTRBNC’ values.  

Additional digitizing may be required in instances where: 

* Newly identified disturbance features that are not included as digitized features within the current datasets, including features in proximity to previously existing (digitized) features, or in newly disturbed areas.  
* Existing features that have changed in shape and size since they were last digitized. In these cases, the entire feature that has changed is re-digitized, not just the additions.   
* Existing features that do not appear to represent the feature correctly e.g., errors or  features that were previously digitized using older/coarser imagery. 

Digitizing Procedures:  

* Starting in the first (top left) 1-km2 grid cell, all visible disturbances digitized.  
* If a feature being digitized leaves the grid cell, it must be digitized completely before  continuing onto the next cell.   
*  If the feature being digitized crosses the AOI boundary of the project, it must be digitized completely before continuing onto the next cell.  
* Features are only divided into separate entries when an attribute changes, such as the  underlying imagery date, the width of a road, trail turning into a road, etc. 

Identifying Potential Disturbances: 

* When potential disturbances are identified, **Supporting layers** (e.g., fire history, quartz and  placer claims, watercourses) are used to help identify the feature and decide if it is a  disturbance.   
* The different layers are toggled on and off to help identify the disturbances.  
* Newly noted disturbances must be flagged for field validation. 

Flagging for Field Validation: 

* When disturbance type, spatial boundaries or temporal attribute assignments of digitized  features are uncertain, they are flagged for validation and a value of 1 is assigned to the  ‘FLAG’ field of the attribute table.   
*  When a feature is flagged for validation, it must always have an associated ‘NOTE’ attribute describing why the feature was flagged.


**Project Tables** 

**‘Dating\_Status’ \- Google Sheets** 

**Table 1:** Draft template for the ‘Dating Status’ Google Sheet (additional attributes may be required) 

| GRID\_ ID | PRIORITY  | STATUS  | WHO  | WHEN  | HOURS  | GRID\_STATUS  | FLAG  | NOTES |
| ----- | ----- | ----- | :---: | ----- | :---- | :---- | ----- | :---- |
| 3962 | 1  | 1  | Sage  | 28/11/24  | 0.15  | Done  | 1  | Large temporal gap in available imagery.  |
| 3953  | 1  | 1  | Sage  | 28/11/24  | 0.15  | Done  | 0 |  |

**Disturbance Attribute Table \- QGIS** 

**Table 2**. List of attributes included in the areal and linear disturbance shapefiles.

| Attribute  | Data Type  | Domains  | Description  |
| :---- | :---- | :---- | :---- |
| REF\_ID | String (254) |  | Unique feature reference ID \- leave this blank. |
| DATABASE | String (254) |  | Sub-database to which the feature belongs. |
| TYPE\_INDUSTRY  | Text (20)  | Appendix 1  | Major classification of disturbance feature  by industry  |
| TYPE\_DISTURBANCE  | Text (30)  | Appendix 1  | Sub classification of disturbance feature  |
| CREATED\_BY  | Text (25)  | USER  | User that aged the disturbance |
| CREATED\_DATE  | Date  |  | Date feature was created/digitized  |
| FLAG  | Short Integer  (1) |  | Feature is a high priority for validation (mark  with value 1\) |
| NGHBR\_EST | Short Integer (1) |  | Feature is assigned age estimate based on the date of appearance of an associated feature (mark with a value of 1\) |
| NOTES  | Text (200) |  | Notes  |
| YR\_DSTRBNC | Integer (4) |  | Date of occurrence for a given disturbance identified to the year. |
| YR\_VISIBLE | Integer (4) |  | Year of imagery when disturbance first becomes clearly identifiable, but degree of uncertainty exists (e.g., poor resolution imagery in buffering years). |
| YR\_IMAGERY | Integer (4) |  | Year of imagery used to digitize the feature. In instances where “YR\_DSTRBNC” & “YR\_VISIBLE” fields are blank, this field is referred to as the earliest known date of disturbance. In most instances, disturbance is assumed to predate this. |
| YR\_EST | Integer (4) |  | Based on information gathered, best estimate of the date of occurrence for a given disturbance. |

