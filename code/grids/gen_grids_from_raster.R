# https://stackoverflow.com/questions/64569984/how-to-generate-10x10km-grid-cells-of-all-countries

library(sf)
library(stars)
library(rnaturalearth)

# Raster
r = read_stars("AOOGrid_10x10kmRast/AOOGrid_10x10km.img")

# Polygon
world = ne_countries(scale = "small", returnclass = "sf")
world = st_transform(world, st_crs(r))
pol = world[world$sovereignt == "Nigeria", ]

# Crop
r = r[pol]

# Plot
plot(r, axes = TRUE, reset = FALSE)
plot(st_geometry(world), border = "grey", add = TRUE)
plot(st_geometry(pol), add = TRUE)
