var aoi = ee.FeatureCollection('projects/ee-vernier/assets/lrb_10k').geometry();
var elevation = ee.ImageCollection('NRCan/CDEM').mosaic().clip(aoi);

Export.image.toDrive({
  image: elevation,
  folder: 'gee_data',
  description: 'cdem',
  maxPixels: 1e13,
  crs: 'EPSG:4326',
  scale: 30,
  region: aoi
});
