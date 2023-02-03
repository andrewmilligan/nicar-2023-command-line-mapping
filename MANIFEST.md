Necessary Dependencies
======================

## Data Files

| Path                                       | Source                          |
|--------------------------------------------|---------------------------------|
| `data/metadata.json`                       | [🔗 Link][data-meta]            |
| `data/tn_population_by_tract.csv`          | [🔗 Link][data-pop]             |
| `data/tn_tracts_with_pop_density.geo.json` | [🔗 Link][data-tracts-with-pop] |
| `shapefiles/cb_2021_47_tract_500k.zip`     | [🔗 Link][shapes-tn-tracts]     |
| `shapefiles/cb_2021_us_state_500k.zip`     | [🔗 Link][shapes-states]        |

## Commands for Course

| Command         | Source                                        |
|-----------------|-----------------------------------------------|
| `bash`          | Pre-installed on Mac                          |
| `unzip`         | Pre-installed on Mac                          |
| `csv2json`      | Binary from [d3-dsv][] NPM package            |
| `shp2json`      | Binary from [shapefile][] NPM package         |
| `geo2topo`      | Binary from [topojson-server][] NPM package   |
| `topo2geo`      | Binary from [topojson-client][] NPM package   |
| `topomerge`     | Binary from [topojson-client][] NPM package   |
| `topoquantize`  | Binary from [topojson-client][] NPM package   |
| `toposimplify`  | Binary from [topojson-simplify][] NPM package |
| `geoproject`    | Binary from [d3-geo-projection][] NPM package |
| `geo2svg`       | Binary from [d3-geo-projection][] NPM package |
| `ndjson-split`  | Binary from [ndjson-cli][] NPM package        |
| `ndjson-map`    | Binary from [ndjson-cli][] NPM package        |
| `ndjson-reduce` | Binary from [ndjson-cli][] NPM package        |
| `ndjson-filter` | Binary from [ndjson-cli][] NPM package        |
| `ndjson-join`   | Binary from [ndjson-cli][] NPM package        |
| `ndjson-cat`    | Binary from [ndjson-cli][] NPM package        |

[data-meta]: https://milligan.news/fileshare/nicar-2023-command-line-mapping/data/metadata.json
[data-pop]: https://milligan.news/fileshare/nicar-2023-command-line-mapping/data/tn_population_by_tract.csv
[data-tracts-with-pop]: https://milligan.news/fileshare/nicar-2023-command-line-mapping/data/tn_tracts_with_pop_density.geo.json
[shapes-tn-tracts]: https://milligan.news/fileshare/nicar-2023-command-line-mapping/shapefiles/cb_2021_47_tract_500k.zip
[shapes-states]: https://milligan.news/fileshare/nicar-2023-command-line-mapping/shapefiles/cb_2021_us_state_500k.zip
[d3-dsv]: https://www.npmjs.com/package/d3-dsv
[shapefile]: https://www.npmjs.com/package/shapefile
[topojson-server]: https://www.npmjs.com/package/topojson-server
[topojson-client]: https://www.npmjs.com/package/topojson-client
[topojson-simplify]: https://www.npmjs.com/package/topojson-simplify
[d3-geo-projection]: https://www.npmjs.com/package/d3-geo-projection
[ndjson-cli]: https://www.npmjs.com/package/ndjson-cli
