# Select one FDA and extract streams, lakes, etc.
# PV 2021-11-01

# References
# https://mitchellgritts.com/posts/load-kml-and-kmz-files-into-r/
# download.file('https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/geobase_nhn_rhn/index/nhn_rhn_geobase.kmz', destfile='data/nhn_rhn_geobase.kmz')
# download.file('https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/geobase_nrn_rrn/bc/nrn_rrn_bc_kml_en.kmz', destfile='data/nrn_rrn_bc_kml_en.kmz')
# "https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/geobase_nhn_rhn/gdb_en/10/nhn_rhn_10ab000_gdb_en.zip"
# "http://ftp.maps.canada.ca/pub/nrcan_rncan/vector/geobase_nhn_rhn/gdb_en/08/nhn_rhn_08gabx1_gdb_en.zip"

library(sf)
library(dplyr)

# Select FDA and output file
fda_code <- '09ea'
fdaOut <- paste0('data/fda_',fda_code,'_hydro.gpkg')

# Attributes of interest
boundary <- 'NHN_WORKUNIT_LIMIT_2'
water_poly <- 'NHN_HD_WATERBODY_2'
water_line <- 'NHN_HD_SLWATER_1'
water_line_all <- 'NHN_HN_NLFOW_1' # includes lines thru polygons

# Create tmp folder
if (!dir.exists('tmp')) dir.create('tmp')

# Get NHN list
nhn_list <- st_read('../../gisdata/123/canada.gdb','NHN_INDEX') %>%
    filter(FDA==toupper(fda_code)) %>%
    pull(DATASETNAM)

# Select one NHN
for (i in nhn_list) {

    # Get NHN name
    cat('Download and extracting', i, '...\n')
    flush.console()

    # Download and unzip
    if (!dir.exists(paste0('tmp/nhn/',i))) dir.create(paste0('tmp/nhn/',i), recursive=T)
    if (!file.exists(paste0('tmp/nhn_',i,'.zip'))) {
        nhn1_http <- paste0('https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/geobase_nhn_rhn/gdb_en/',substring(i,1,2),'/nhn_rhn_',i,'_gdb_en.zip')
        download.file(nhn1_http, destfile=paste0('tmp/nhn_rhn_',i,'_gdb_en.zip'))
        unzip(paste0('tmp/nhn_rhn_',i,'_gdb_en.zip'), exdir = paste0('tmp/nhn/',i))
        #file.remove(paste0('tmp/nhn_',i,'.zip'))
    }

    # Select gdb - filenames vary so search for '.gdb' pattern
    gdb <- list.files(paste0('tmp/nhn/',i),'.gdb') 

    # Lakes and rivers
    lakes1 <- read_sf(paste0('tmp/nhn/',i,'/',gdb), water_poly) %>% 
        st_zm() %>% 
        st_transform(3578)
    if (length(nhn_list)>1) {
        if (i==nhn_list[1]) {
            lakes <- lakes1
        } else {
            lakes <- rbind(lakes, lakes1)
        }
    } else {
        lakes <- lakes1
    }

    # Streams
    streams1 <- read_sf(paste0('tmp/nhn/',i,'/',gdb), water_line) %>% 
        st_zm() %>% 
        st_transform(3578)
    if (length(nhn_list)>1) {
        if (i==nhn_list[1]) {
            streams <- streams1
        } else {
            streams <- rbind(streams, streams1)
        }
    } else {
        streams <- streams1
    }
    #file.remove(paste0('tmp/nhn/',i,'/',gdb))
}

# Write to geopackage
st_write(lakes, fdaOut, 'lakes_rivers', delete_layer=T)
st_write(streams, fdaOut, 'streams', delete_layer=T)

# Delete tmp files
#unlink('tmp/nhn', recursive=TRUE)
