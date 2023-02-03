Making Maps with Command Line Tools
===================================

We assume that you've done part 1 first.

First, we need to get all the state boundaries in the U.S.:

```shell
cp shapefiles/cb_2021_us_state_500k.zip inputs/
unzip -o -d inputs/ inputs/cb_2021_us_state_500k.zip
```

Next we convert the U.S. into GeoJSON and split out its features:

```shell
shp2json inputs/cb_2021_us_state_500k.shp \
  | ndjson-split 'd.features' \
  | ndjson-map '
      d.properties.type = "state",
      d.properties.fill = "#FFFEF3",
      d
    ' \
  > work/us_states.ndjson
```

Now we'll pull out Tennessee's tracts again:

```shell
ndjson-cat data/tn_tracts_with_pop_density.geo.json \
  | ndjson-split 'd.features' \
  > work/tn_tracts_with_pop_density.ndjson
```

And combine all of those features into one big GeoJSON:

```shell
(
  cat work/us_states.ndjson;
  cat work/tn_tracts_with_pop_density.ndjson;
) \
  | ndjson-reduce \
  | ndjson-map '{ type: "FeatureCollection", features: d }' \
  > work/states_and_tracts.geo.json
```

Now that we have everything in one GeoJSON file we can project it all together:

```shell
cat work/states_and_tracts.geo.json \
  | geoproject '
      d3.geoConicEqualArea()
        .parallels([35.4,36.3])
        .rotate([86, 0])
    ' \
  | geoproject '
      d3.geoIdentity()
        .fitExtent(
          [[50, 50], [910, 550]],
          d.features.find(f => f.properties.STATEFP === "47"),
        )
    ' \
  | geoproject '
      d3.geoIdentity()
        .clipExtent([[0,0], [960, 600]])
    ' \
  > work/states_and_tracts_projected.geo.json
```

Now let's simplify it as TopoJSON and convert it back to GeoJSON:

```shell
cat work/states_and_tracts_projected.geo.json \
  | geo2topo boundaries=- \
  | toposimplify -p 1 -f \
  | topoquantize 1e5 \
  | topo2geo -n boundaries=- \
  > work/states_and_tracts_projected_simplified.ndjson
```

Let's grab the internal state boundaries:

```shell
cat work/states_and_tracts_projected_simplified.ndjson \
  | ndjson-filter 'd.properties.type === "state"' \
  | geo2topo -n boundaries=- \
  | topomerge --mesh -f 'a !== b' boundaries=boundaries \
  | topo2geo -n boundaries=- \
  | ndjson-map '
      d.properties = {"stroke": "#B6B07E"},
      d
    ' \
  > work/us_state_borders.ndjson
```

And also the county boundaries:

```shell
cat work/states_and_tracts_projected_simplified.ndjson \
  | ndjson-filter 'd.properties.type === "tract"' \
  | geo2topo -n boundaries=- \
  | topomerge -k 'd.properties.GEOID.slice(0, 5)' boundaries=boundaries \
  | topomerge --mesh -f 'a !== b' boundaries=boundaries \
  | topo2geo -n boundaries=- \
  | ndjson-map '
      d.properties = {"stroke": "#928273"},
      d
    ' \
  > work/tn_county_borders.ndjson
```

And make one big SVG:

```shell
(
  cat work/states_and_tracts_projected_simplified.ndjson;
  cat work/us_state_borders.ndjson;
  cat work/tn_county_borders.ndjson;
) \
  | geo2svg -n --stroke none -p 1 -w 960 -h 600 \
  > outputs/advanced_tn_tract_population_density_sqrt.svg
```
