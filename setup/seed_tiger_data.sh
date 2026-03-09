#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET_GEOGRAPHIES="${TIGER_GEOGRAPHIES:-county state}"

for geography in $TARGET_GEOGRAPHIES; do
  case "$geography" in
    county)
      DATA_DIR="${COUNTY_DATA_DIR:-${REPO_ROOT}/data/tiger_counties}"
      TABLE_NAME="${COUNTY_TABLE_NAME:-public.us_counties}"
      ;;
    state)
      DATA_DIR="${STATE_DATA_DIR:-${REPO_ROOT}/data/tiger_states}"
      TABLE_NAME="${STATE_TABLE_NAME:-public.us_states}"
      ;;
    *)
      echo "Unsupported geography in TIGER_GEOGRAPHIES: $geography" >&2
      echo "Supported options: county, state" >&2
      exit 1
      ;;
  esac

  echo "Processing TIGER ${geography} data..."
  TIGER_GEOGRAPHY="$geography" DATA_DIR="$DATA_DIR" "${SCRIPT_DIR}/download_tiger_data.sh"
  TIGER_GEOGRAPHY="$geography" DATA_DIR="$DATA_DIR" TABLE_NAME="$TABLE_NAME" "${SCRIPT_DIR}/import_tiger_data.sh"
  echo "Finished ${geography}."
  echo
done
