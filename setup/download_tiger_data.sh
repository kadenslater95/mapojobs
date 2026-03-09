#!/usr/bin/env bash
set -euo pipefail

TIGER_YEAR="${TIGER_YEAR:-2025}"
TIGER_GEOGRAPHY="${TIGER_GEOGRAPHY:-county}"

case "$TIGER_GEOGRAPHY" in
  county)
    DEFAULT_DATA_DIR="./data/tiger_counties"
    TIGER_FOLDER="COUNTY"
    ;;
  state)
    DEFAULT_DATA_DIR="./data/tiger_states"
    TIGER_FOLDER="STATE"
    ;;
  *)
    echo "Unsupported TIGER_GEOGRAPHY value: $TIGER_GEOGRAPHY" >&2
    echo "Supported options: county, state" >&2
    exit 1
    ;;
esac

DATA_DIR="${DATA_DIR:-${DEFAULT_DATA_DIR}}"
BASENAME="tl_${TIGER_YEAR}_us_${TIGER_GEOGRAPHY}"
ZIP_NAME="${BASENAME}.zip"
ZIP_URL="https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/${TIGER_FOLDER}/${ZIP_NAME}"

mkdir -p "$DATA_DIR"

required_files=(
  "${DATA_DIR}/${BASENAME}.shp"
  "${DATA_DIR}/${BASENAME}.shx"
  "${DATA_DIR}/${BASENAME}.dbf"
  "${DATA_DIR}/${BASENAME}.prj"
)

all_present=true
for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    all_present=false
    break
  fi
done

if [ "$all_present" = true ]; then
  echo "TIGER ${TIGER_GEOGRAPHY} shapefile already present in ${DATA_DIR}"
  exit 0
fi

tmp_zip="${DATA_DIR}/${ZIP_NAME}"

echo "Downloading ${ZIP_URL}"
curl -fL "$ZIP_URL" -o "$tmp_zip"

echo "Extracting ${ZIP_NAME} into ${DATA_DIR}"
unzip -o "$tmp_zip" -d "$DATA_DIR"

rm -f "$tmp_zip"

echo "${TIGER_GEOGRAPHY^} TIGER files are ready."
