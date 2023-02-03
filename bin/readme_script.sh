#!/bin/bash

## 1. Get your data
cp data/tn_population_by_tract.csv inputs/

## 2. Get your geographical boundaries
cp shapefiles/cb_2021_47_tract_500k.zip inputs/
unzip -o -d inputs/ inputs/cb_2021_47_tract_500k.zip

## 3. Convert shapefile to GeoJSON
shp2json inputs/cb_2021_47_tract_500k.shp -o work/tn_tracts.geo.json

## 4. Project our geography
cat work/tn_tracts.geo.json \
  | geoproject 'd3.geoConicEqualArea().parallels([35.4,36.3]).rotate([86, 0]).fitSize([960, 960], d)' \
  > work/tn_tracts_projected.geo.json

## 5. Join our data with our geography
cat work/tn_tracts_projected.geo.json \
  | ndjson-split 'd.features' \
  > work/tn_tracts_projected.ndjson

csv2json -n inputs/tn_population_by_tract.csv \
  | ndjson-map '{ id: d.geoid.split("US")[1], population: +d.B01003001 }' \
  > work/tn_population_by_tract.ndjson

ndjson-join 'd.id' 'd.properties.GEOID' \
  work/tn_population_by_tract.ndjson \
  work/tn_tracts_projected.ndjson \
  > work/tn_population_and_tracts_projected.ndjson

cat work/tn_population_and_tracts_projected.ndjson \
  | ndjson-map '
      population = d[0].population,
      m2permi2 = 1609.34 * 1609.34,
      area = d[1].properties.ALAND,
      d[1].properties.density = Math.floor(population / area * m2permi2),
      d[1]
    ' \
  > work/tn_tracts_projected_with_population.ndjson

cat work/tn_tracts_projected_with_population.ndjson \
  | ndjson-reduce \
  | ndjson-map '{ type: "FeatureCollection", features: d }' \
  > work/tn_tracts_projected_with_population.geo.json

## 6. Simplifying with TopoJSON
cat work/tn_tracts_projected_with_population.geo.json \
  | geo2topo tracts=- \
  > work/tn_tracts_projected_with_population.topo.json

cat work/tn_tracts_projected_with_population.topo.json \
  | toposimplify -p 1 -f \
  > work/tn_tracts_projected_simplified_with_population.topo.json

cat work/tn_tracts_projected_simplified_with_population.topo.json \
  | topoquantize 1e5 \
  > work/tn_tracts_projected_simplified_quantized_with_population.topo.json

## 7. Give it some color
cat work/tn_tracts_projected_simplified_quantized_with_population.topo.json \
  | topo2geo tracts=- \
  | ndjson-map \
      -r d3array=d3-array \
      -r d3scale=d3-scale \
      -r d3chroma=d3-scale-chromatic \
      '
        z = d3scale.scaleSequential(d3chroma.interpolateMagma).domain([100, 0]),
        d.features.forEach((f) => {
          f.properties.fill = z(Math.sqrt(f.properties.density));
        }),
        d
      ' \
  | ndjson-split 'd.features' \
  > work/tn_tracts_projected_simplified_quantized_with_population_colors.ndjson

cat work/tn_tracts_projected_simplified_quantized_with_population_colors.ndjson \
  | geo2svg -n --stroke none -p 1 -w 960 -h 960 \
  > outputs/tn_tract_population_density_sqrt.svg

## 8. Add county boundaries
cat work/tn_tracts_projected_simplified_quantized_with_population.topo.json \
  | topomerge -k 'd.properties.GEOID.slice(0, 5)' counties=tracts \
  | topomerge --mesh -f 'a !== b' counties=counties \
  | topo2geo -n counties=- \
  | ndjson-map '
      d.properties = {"stroke": "#000", "stroke-opacity": 0.3},
      d
    ' \
  > work/tn_counties.ndjson

(
  cat work/tn_tracts_projected_simplified_quantized_with_population_colors.ndjson;
  cat work/tn_counties.ndjson;
) \
  | geo2svg -n --stroke none -p 1 -w 960 -h 960 \
  > outputs/tn_tract_population_density_sqrt.svg
