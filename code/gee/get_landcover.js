var aoi = ee.FeatureCollection("projects/ee-vernier/assets/lrb_10k");

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_1984').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_1984',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_1989').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_1989',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_1994').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_1994',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_1999').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_1999',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_2004').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_2004',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_2009').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_2009',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_2014').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_2014',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

var lcc = ee.Image('projects/sat-io/open-datasets/CA_FOREST_LC_VLCE2/CA_forest_VLCE2_2019').clip(aoi);
Export.image.toDrive({
  image: lcc,
  folder: 'gee_data',
  description: 'lc_2019',
  maxPixels: 3000000000,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});

