Preparation of digitizing data packages
Pierre Vernier
2023-06-01

Data:

Input data for the scripts are located on the shared google drive:

  - H:\Shared drives\Disturbance Mapping (digitizing)\Data\fda_10ab
  - H:\Shared drives\Disturbance Mapping (digitizing)\Data\fda_10ad
  - H:\Shared drives\Disturbance Mapping (digitizing)\Data\klaza
  - H:\Shared drives\Disturbance Mapping (digitizing)\Data\clear_creek

Scripts:

# 1_gen_100k_grid.R
  - Create Yukon-wide 100-km2 grid
  
# 2_fix_fda10ab_and_merge.R
  - Convert linear and areal disturbance shapefiles to GPKG layers and rename fields to be consistent with YG
  - Merge BEACONs and YG disturbance datasets for FDA 10AB

# 2_fix_klaza.R
  - Convert linear and areal disturbance shapefiles to GPKG layers and rename fields to be consistent with YG

# 3_gen_data_packages.R
  - Create data packages for digitizing
  
# 4_id_priority_grids.R
  - Prioritizing 1-km grids to digitize based on YG and SPOT years
