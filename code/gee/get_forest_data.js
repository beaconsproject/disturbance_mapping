var aoi = ee.FeatureCollection('projects/ee-vernier/assets/sda10ab_50k').geometry();

// Forest harvest
var ca_forest_harvest = ee.Image("projects/sat-io/open-datasets/CA_FOREST/CA_Forest_Harvest_1985-2020").clip(aoi);
Export.image.toDrive({
  image: ca_forest_harvest,
  folder: 'gee_data',
  description: 'harvest_1985-2020',
  maxPixels: 1e13,
  crs: 'EPSG:3578',
  scale: 30,
  region: aoi
});

// Tree species
//var D2SC = ee.Image("projects/sat-io/open-datasets/CA_FOREST/DISTANCE2SECOND");
//var membership_likelihood_prob = ee.ImageCollection("projects/sat-io/open-datasets/CA_FOREST/SPECIES_CLASS_MEMBERSHIP_PROBABILITIES");
var lead_tree_species = ee.Image("projects/sat-io/open-datasets/CA_FOREST/LEAD_TREE_SPECIES");
Export.image.toDrive({
  image: lead_tree_species,
  folder: 'gee_data',
  description: 'tree_species',
  maxPixels: 1e13,
  crs: 'EPSG:3578',
  scale: 30,
  region: aoi
});

// Forest age
//var age_appro = ee.Image("projects/sat-io/open-datasets/CA_FOREST/CA_forest_age_2019_approach");
var age = ee.Image("projects/sat-io/open-datasets/CA_FOREST/CA_forest_age_2019");
Export.image.toDrive({
  image: age,
  folder: 'gee_data',
  description: 'forest_age',
  maxPixels: 1e13,
  crs: 'EPSG:3578',
  scale: 30,
  region: aoi
});


// Forest fire
var ca_forest_fire = ee.Image("projects/sat-io/open-datasets/CA_FOREST/CA_Forest_Fire_1985-2020");
Export.image.toDrive({
  image: ca_forest_fire,
  folder: 'gee_data',
  description: 'fire_1985-2020',
  maxPixels: 1e13,
  crs: 'EPSG:3578',
  scale: 30,
  region: aoi
});
