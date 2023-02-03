#!/bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
cd "$ROOT_DIR"

. "${ROOT_DIR}/bin/configure_shell.sh"

echo "Setting up project dependencies"

echo "=> 📆 Making sure repo is up-to-date..."
git pull

echo "=> 📂 Installing Node dependencies..."
npm install

echo "=> 📊 Pulling data files..."
DATA_FILES=(
  "data/metadata.json"
  "data/tn_population_by_tract.csv"
  "data/tn_tracts_with_pop_density.geo.json"
)
for DATA_FILE in "${DATA_FILES[@]}"; do
  echo "  - ${DATA_FILE}"
  curl \
    --silent \
    -o "${DATA_FILE}" \
    "https://milligan.news/fileshare/nicar-2023-command-line-mapping/${DATA_FILE}"
done

echo "=> 🌐 Pulling shapefiles..."
SHAPE_FILES=(
  "shapefiles/cb_2021_47_tract_500k.zip"
  "shapefiles/cb_2021_us_state_500k.zip"
)
for SHAPE_FILE in "${SHAPE_FILES[@]}"; do
  echo "  - ${SHAPE_FILE}"
  curl \
    --silent \
    -o "${SHAPE_FILE}" \
    "https://milligan.news/fileshare/nicar-2023-command-line-mapping/${SHAPE_FILE}"
done

echo
echo "Testing project scripts"
echo "=> 🔰 Testing basic course..."
"${ROOT_DIR}/bin/readme_script.sh" > /dev/null

echo "=> 🦾 Testing advanced course..."
"${ROOT_DIR}/bin/advanced_script.sh" > /dev/null

echo "Done! Everything should be ready to go!"
