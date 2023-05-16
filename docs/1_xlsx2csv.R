# Convert datasets.xlsx to individual csv files
# PV 2023-05-15

library(readxl)
library(tidyverse)

# Location of datasets.xlsx
xlsx <- 'C:/Users/PIVER37/OneDrive/Documents/datasets.xlsx'

# View worksheets
#excel_sheets(xlsx)

# View metadata i.e., attributes in common with all worksheets
#read_excel(xlsx, sheet='Meta')

# Read Global datasets and write to csv file
global_data <- read_excel(xlsx, sheet='Global') %>%
    select(Class, Layer, Type, URL)
write_csv(global_data, '../1_datasets/datasets_global.csv')

# Read Canada datasets and write to csv file
canada_data <- read_excel(xlsx, sheet='Canada') %>%
    select(Class, Layer, Type, URL)
write_csv(canada_data, '../1_datasets/datasets_canada.csv')

# Read YT datasets and write to csv file
yt_data <- read_excel(xlsx, sheet='YT') %>%
    select(Class, Layer, Type, URL)
write_csv(yt_data, '../1_datasets/datasets_yt.csv')

# Read BC datasets and write to csv file
bc_data <- read_excel(xlsx, sheet='BC') %>%
    select(Class, Layer, Type, URL)
write_csv(bc_data, '../1_datasets/datasets_bc.csv')

# Read NT datasets and write to csv file
nt_data <- read_excel(xlsx, sheet='NT') %>%
    select(Class, Layer, Type, URL)
write_csv(nt_data, '../1_datasets/datasets_nt.csv')

# Read AB datasets and write to csv file
ab_data <- read_excel(xlsx, sheet='AB') %>%
    select(Class, Layer, Type, URL)
write_csv(ab_data, '../1_datasets/datasets_ab.csv')
