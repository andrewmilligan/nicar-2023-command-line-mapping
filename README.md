Making Maps with Command Line Tools
===================================

Today we're going to be working with several command line tools to go from
a shapefile all the way to an SVG of a choropleth map. We're going to take
a look at several different mapping file formats, talk about their pros and
cons, and see how JSON-based map formats open up a world of exciting
possibilities by letting us manipulate maps from scriptable tools.

## 0. Configure your shell

Before we start we need to configure our shell a little bit. This is specific
to the context of our hands-on class at NICAR and isn't something you would
generally need to do.

```shell
source bin/configure_shell.sh
```

Just in case your command prompt now looks super funky and messed up you can
run this instead but you shouldn't have to!

```shell
source bin/configure_basic_shell.sh
```

## 1. Get your data

Normally you would come to a project with a dataset that you are trying to map,
whether you've pulled data from the Census, queried an API for election
results, or even collected a custom dataset. For today we already have a simple
dataset ready to go: total population estimates by Census tract in Tennessee.

Let's start by making a fresh copy of the dataset in an "inputs" directory:

```shell
cp data/tn_population_by_tract.csv inputs/
```

## 2. Get your geographical boundaries

Now that we have our data, we need the geographical boundaries that we're going
to map it in. [The Census publishes a lot of shapefiles][census-geo] that can
be really useful for this kind of thing. Particularly, their "cartographic
boundary files" are perfect for creating map graphics; they've already been
simplified a bit so that they're a little easier to work with, and the
lost geographical precision won't generally be a problem in most graphics.

We're going to start by grabbing [a tract-level shapefile of
Tennessee][census-tn-tract]. Depending on the resolution of your data you could
instead pick just about any level in the Census Bureau's hierarchy of
geographic entities like counties, congressional districts, and so on. For
today we already have that map locally, so we'll copy it into our "inputs"
directory:

```shell
cp shapefiles/cb_2021_47_tract_500k.zip inputs/
```

The map comes from the Census as a zip archive of a bunch of files, so the next
thing we need to do is unzip the archive:

```shell
unzip -o -d inputs/ inputs/cb_2021_47_tract_500k.zip
```

(Note: the `-o` flag being passed to `unzip` means that we'll overwrite any
existing files and the `-d inputs/` means that we should unzip the archive into
the `inputs/` directory, keeping all our map inputs organized.)

## 3. Convert shapefile to GeoJSON

The bundle of files that we just unzipped make up a shapefile, which is
a common way to encode geographical information. It's great for a lot of
applications, but today we're going to explore how we can harness the power of
JSON-manipuation tools to make our mapping lives easier, so we're going to need
to convert our map into a JSON-based format. Luckily, there are two such
formats that enjoy widespread use: GeoJSON and TopoJSON. We're going to be
leveraging both today, but we're going to start by converting our shapefile
into a GeoJSON file:

```shell
shp2json inputs/cb_2021_47_tract_500k.shp -o work/tn_tracts.geo.json
```

## 4. Project our geography

Right now our geography is represented in lattitude and longitude, which are
spherical coordinates representing points on the globe. We want to flatten our
map onto a plane so that we can show it on a screen. That process is called
projection. Now that we have our map in GeoJSON format we can use the
`geoproject` tool from the `d3-geo-projection` package:

```shell
cat work/tn_tracts.geo.json \
  | geoproject 'd3.geoConicEqualArea().parallels([35.4,36.3]).rotate([86, 0]).fitSize([960, 960], d)' \
  > work/tn_tracts_projected.geo.json
```

## 5. Join our data with our geography

We're going to be joining our dataset into our map file so that at the end of
the day we know how to color each tract. This is where we're really going to
start taking advantage of the fact that our map is now a big JSON file. That
means we can use some general-purpose JSON tools that actually have nothing to
do with mapping!

Specifically, we're going to use several commands from the `ndjson-cli`
package, which is built to work with "newline-delimited JSON" files (or
"ndjson" for short). Newline-delimited JSON files can contain multiple JSON
values separated by newlines (`\n`). The `ndjson-cli` package provides some
useful tools for treating these files like JavaScript arrays, allowing us to
map across each item in the file, filter the items according to some condition,
or reduce all the items into one summary of them all.

First we have to split the features in our GeoJSON file into an ndjson format:

```shell
cat work/tn_tracts_projected.geo.json \
  | ndjson-split 'd.features' \
  > work/tn_tracts_projected.ndjson
```

We're going to join our data into our geography in a second, but first we need
to do a little prep work on our dataset. We're going to do three things in one
chain of commands: convert our CSV dataset into a JSON array of objects, and
map across that array to make sure we only get the data we need.

```shell
csv2json -n inputs/tn_population_by_tract.csv \
  | ndjson-map '{ id: d.geoid.split("US")[1], population: +d.B01003001 }' \
  > work/tn_population_by_tract.ndjson
```

Now we're ready to join the two:

```shell
ndjson-join 'd.id' 'd.properties.GEOID' \
  work/tn_population_by_tract.ndjson \
  work/tn_tracts_projected.ndjson \
  > work/tn_population_and_tracts_projected.ndjson
```

If you take a look at the file we just created, you'll see that each line is
a two element array. The first element is an entry from our dataset and the
second element is a GeoJSON feature from our geography. We want to make a map
though, so we'll map across this joined dataset again to make sure we only have
valid GeoJSON, simultaneously calculating population _density_ from the total
population estimate and the `ALAND` property of our geographical features:

```shell
cat work/tn_population_and_tracts_projected.ndjson \
  | ndjson-map '
      population = d[0].population,
      m2permi2 = 1609.34 * 1609.34,
      area = d[1].properties.ALAND,
      d[1].properties.density = Math.floor(population / area * m2permi2),
      d[1]
    ' \
  > work/tn_tracts_projected_with_population.ndjson
```

And finally we can reassemble our newline-delimited features into a full
GeoJSON file again with a combination of `ndjson-reduce` and `ndjson-map`:

```shell
cat work/tn_tracts_projected_with_population.ndjson \
  | ndjson-reduce \
  | ndjson-map '{ type: "FeatureCollection", features: d }' \
  > work/tn_tracts_projected_with_population.geo.json
```

## 6. Simplifying with TopoJSON

Now we're going to convert our map from the GeoJSON format into the TopoJSON
format:

```shell
cat work/tn_tracts_projected_with_population.geo.json \
  | geo2topo tracts=- \
  > work/tn_tracts_projected_with_population.topo.json
```

Because TopoJSON encodes the boundaries, or "arcs", that make up geographical
shapes we can simplify each of those arcs without creating any gaps or
misalignment between contiguous shapes. We can simplify our TopoJSON with the
`toposimplify` command:

```shell
cat work/tn_tracts_projected_with_population.topo.json \
  | toposimplify -p 1 -f \
  > work/tn_tracts_projected_simplified_with_population.topo.json
```

The simplification makes the filesize a lot smaller and helps make sure we're
not having to deal with way more precision and detail than you'll ever be able
to see in the final graphic. Similarly, many of the coordinates in our file
have far more decimal precision than we need, and we can further shrink the
file size by limiting ourselves to a more reasonable level of precision with
the `topoquantize` command:

```shell
cat work/tn_tracts_projected_simplified_with_population.topo.json \
  | topoquantize 1e5 \
  > work/tn_tracts_projected_simplified_quantized_with_population.topo.json
```

## 7. Give it some color

We've added our data to our geographical information and we've simplified our
geography to a precision suitable for our display, so now we're ready to start
thinking about what it looks like! Because this is a choropleth map, we need to
figure out which color to make each tract. We'll do that with a few D3
utilities by setting up a scale that will convert the square root of a tract's
population density into a color.

```shell
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
```

Now we can convert that into an SVG so we can see what it looks like:

```shell
cat work/tn_tracts_projected_simplified_quantized_with_population_colors.ndjson \
  | geo2svg -n --stroke none -p 1 -w 960 -h 960 \
  > outputs/tn_tract_population_density_sqrt.svg
```

## 8. Add county boundaries

We can also add some reference geography to our map so that readers see some
shapes that might be a litte more familiar. We can pull out the county borders
by merging all the tracts that roll up into a single county and then making
a mesh of their borders:

```shell
cat work/tn_tracts_projected_simplified_quantized_with_population.topo.json \
  | topomerge -k 'd.properties.GEOID.slice(0, 5)' counties=tracts \
  | topomerge --mesh -f 'a !== b' counties=counties \
  | topo2geo -n counties=- \
  | ndjson-map '
      d.properties = {"stroke": "#000", "stroke-opacity": 0.3},
      d
    ' \
  > work/tn_counties.ndjson
```

And then we can pipe all of those features into our SVG:

```shell
(
  cat work/tn_tracts_projected_simplified_quantized_with_population_colors.ndjson;
  cat work/tn_counties.ndjson;
) \
  | geo2svg -n --stroke none -p 1 -w 960 -h 960 \
  > outputs/tn_tract_population_density_sqrt.svg
```

[census-geo]: https://www2.census.gov/geo/tiger/
[census-tn-tract]: https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_47_tract_500k.zip
