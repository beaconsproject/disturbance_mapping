# Worflows

## Issues

- Deleting with areas that have been mapped by both YG and BP e.g., FDA 10AB: YG -> BP -> YG
- Adding existing projects (Klaza, Clear Creek, Finlayson, Little Rancheria)

## Merging existing projects

This workflow describes the steps to replicate the creating of the current disturbance database. Any new projects should follow the workflow described in the new_projects.md file.

1. Prepare and clean each project database (fda10ab, fda10aa1, fda10aa2, fda10ab, fda10ad, fda10bc, tu_ball, tu_cho)
    - mapping extent, linear disturbances, areal disturbances
2. Merge projects together using rbind (projects are not overlapping)
    - mapping extent, linear disturbances, areal disturbances
3. Remove YG linear and areal disturbances from BP mapping extent
4. Merge BP and YG linear and areal disturbances using rbind (BP and YG are not overlapping)
    - mapping extent, linear disturbances, areal disturbances [BP_YG_LINE, BP_YG_POLY]
5. Prepare BC linear and areal disturbances
6. Merge BC linear and areal disturbances with BP_YG_LINE and BP_YG_POLY [LINEAR, AREAL]
7. Update Little Rancheria
    - Remove LRH mapping extent from LINEAR and AREAL
    - Merge LRH linear and areal disturbances with LINEAR and AREAL using rbind [LINEAR, AREAL]
8. Update Finlayson
    - Remove FH mapping extent from LINEAR and AREAL
    - Merge FH linear and areal disturbances with LINEAR and AREAL using rbind [LINEAR, AREAL]
9. Update Clear Creek
    - Remove CCH mapping extent from LINEAR and AREAL
    - Merge CCH linear and areal disturbances with LINEAR and AREAL using rbind [LINEAR, AREAL]
10. Update Klaza
    - Remove KH mapping extent from LINEAR and AREAL
    - Merge KH linear and areal disturbances with LINEAR and AREAL using rbind [LINEAR, AREAL]

## Creating and merging a new project

This workflow should be used when creating a new project and merging it with the most recent disturbance database.

1. Make a copy of existing disturbance database to an archived version e.g., disturbances_2026-08-11.gpkg
2. Create AOI for project of interest (EPSG:3578) [AOI]
3. Use AOI to select (clip) all intersecting 10x10km grid cells [AOI_GRID]
4. Use AOI_GRID to clip all linear and areal features and save to new layers [AOI_GRID_LINE, AOI_GRID_POLY]
5. Delete all selected linear and area features from existing database [LINEAR_NEW, AREAL_NEW]
6. Digitize new feature, removed features no longer visible, modify erroneous features [AOI_GRID_LINE, AOI_GRID_POLY]
	- make sure the entire AOI or AOI_GRID is reviewed
7. Replace gaps in disturbance database with AOI_GRID_LINE and AOI_GRID_POLY [LINEAR_NEW, AREAL_NEW]
8. Validate and save updated disturbance database