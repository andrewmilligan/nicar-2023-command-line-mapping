Setup Notes
===========

These are instructions on how to set this course up ahead of time in
a computer lab setting.

## Setup Steps

First, a couple of assumptions:

* You're running this on a Mac with a terminal and all the basic command-line
tools setup (namely `bash`, `git`, `curl`, `zip`). Bash does _not_ need to
be the default shell, but it _does_ need to be installed, which should be
true out of the box.
* You have a network connection to clone a repo from GitHub and download
a few data files.
* You have a version of Node installed (at least major version 16, e.g.
  `v16.15.0`, but more recent is fine if a more recent version is already
  available on the machine).

If those assumptions hold, you should be good to follow these steps:

1. Clone this repo into the appropriate place. This is the directory we'll be
   working in.
2. Run the install/verification script from the root of the repo:
   ```shell
   bin/setup_class.sh
   ```
   That should grab all the necessary data files, put them in the right place,
   install dependencies from NPM. Note that if you downloaded a zip archive of
   the repo rather than cloning it you will see a warning. If that was
   intentional then feel free to disregard the warning.

If the setup script completes successfully and tells you that everything works
then you should be good to go!

### In case the setup script fails

Here's everything that the setup script does in case you need to do it by hand
for some reason. This assumes that you've already cloned the repo to the
correct place on the computer (or acquired the code by other means).

* Make sure the repo is up-to-date with `git pull`
* Install NPM depdendencies with `npm install`
* Download the data files into the table below to the corresponding paths

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
| `node`          | Any version 16 or later                       |
| `npm`           | Included with Node                            |
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
