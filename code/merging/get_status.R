# Merging BP data with YG data
# 2023-05-30
# PV

library(sf)
library(dplyr)
library(googlesheets4)

# Google drive projects location
projects <- 'H:/Shared drives/Disturbance Mapping (digitizing)/Projects/'

# Join "digitizing_status" spreadsheets to grid_100k layers and merge FDAs
fda_10aa_001_sheet <- read_sheet('14WEbqjB_3xVwuxKis1RJtjs9PfN7rkKLnOwQ8hq7qoU', sheet='FDA_10AA_001') %>%
    mutate(id=`Grid ID`) %>% select(id, Done)
fda_10aa_001 <- st_read(paste0(projects, 'FDA_10AA_001/Data_package.gpkg'), 'Grid_100k') %>%
    left_join(fda_10aa_001_sheet) %>%
    mutate(status=Done, Done=NULL)
st_write(fda_10aa_001, paste0(projects, 'FDA_10AA_001/Data_package.gpkg'), 'Grid_100k', delete_layer=T)

fda_10aa_002_sheet <- read_sheet('14WEbqjB_3xVwuxKis1RJtjs9PfN7rkKLnOwQ8hq7qoU', sheet='FDA_10AA_002') %>%
    mutate(id=`Grid ID`) %>% select(id, Done)
fda_10aa_002 <- st_read(paste0(projects, 'FDA_10AA_002/Data_package.gpkg'), 'Grid_100k') %>%
    left_join(fda_10aa_002_sheet) %>%
    mutate(status=Done, Done=NULL)
st_write(fda_10aa_002, paste0(projects, 'FDA_10AA_002/Data_package.gpkg'), 'Grid_100k', delete_layer=T)

fda_10ad_sheet <- read_sheet('14WEbqjB_3xVwuxKis1RJtjs9PfN7rkKLnOwQ8hq7qoU', sheet='FDA_10AD') %>%
    mutate(id=`Grid ID`) %>% select(id, Done)
fda_10ad <- st_read(paste0(projects, 'FDA_10AD/Data_package.gpkg'), 'Grid_100k') %>%
    left_join(fda_10ad_sheet) %>%
    mutate(status=Done, Done=NULL)
st_write(fda_10ad, paste0(projects, 'FDA_10AD/Data_package.gpkg'), 'Grid_100k', delete_layer=T)

fda_10bc_sheet <- read_sheet('14WEbqjB_3xVwuxKis1RJtjs9PfN7rkKLnOwQ8hq7qoU', sheet='FDA_10BC') %>%
    mutate(id=`Grid ID`) %>% select(id, Done)
fda_10bc <- st_read(paste0(projects, 'FDA_10BC/Data_package.gpkg'), 'Grid_100k') %>%
    left_join(fda_10bc_sheet) %>%
    mutate(status=Done, Done=NULL)
st_write(fda_10bc, paste0(projects, 'FDA_10BC/Data_package.gpkg'), 'Grid_100k', delete_layer=T)

fda_grid_100k <- bind_rows(c(fda_10aa_001, fda_10aa_002, fda_10ad, fda_10bc))
