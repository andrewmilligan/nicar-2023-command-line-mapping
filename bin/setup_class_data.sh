#!/bin/bash

set -e

DATA_FILES=(
  "data/metadata.json"
  "data/tn_population_by_tract.csv"
  "data/tn_tracts_with_pop_density.geo.json"
)

echo "Pulling data files..."
for DATA_FILE in "${DATA_FILES[@]}"; do
  echo "=> ${DATA_FILE}"
  curl \
    --silent \
    -o "${DATA_FILE}" \
    "https://milligan.news/fileshare/nicar-2023-command-line-mapping/${DATA_FILE}"
done

SHAPE_FILES=(
  "shapefiles/cb_2021_47_tract_500k.zip"
  "shapefiles/cb_2021_us_state_500k.zip"
)
echo "Pulling shapefiles..."
for SHAPE_FILE in "${SHAPE_FILES[@]}"; do
  echo "=> ${SHAPE_FILE}"
  curl \
    --silent \
    -o "${SHAPE_FILE}" \
    "https://milligan.news/fileshare/nicar-2023-command-line-mapping/${SHAPE_FILE}"
done

echo "Done!"
