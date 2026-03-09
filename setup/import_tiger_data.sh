#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-mapojobs}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD:-devpassword}"

TIGER_YEAR="${TIGER_YEAR:-2025}"
TIGER_GEOGRAPHY="${TIGER_GEOGRAPHY:-county}"

case "$TIGER_GEOGRAPHY" in
  county)
    DEFAULT_DATA_DIR="./data/tiger_counties"
    DEFAULT_TABLE_NAME="public.us_counties"
    ;;
  state)
    DEFAULT_DATA_DIR="./data/tiger_states"
    DEFAULT_TABLE_NAME="public.us_states"
    ;;
  *)
    echo "Unsupported TIGER_GEOGRAPHY value: $TIGER_GEOGRAPHY" >&2
    echo "Supported options: county, state" >&2
    exit 1
    ;;
esac

DATA_DIR="${DATA_DIR:-${DEFAULT_DATA_DIR}}"
TABLE_NAME="${TABLE_NAME:-${DEFAULT_TABLE_NAME}}"
BASENAME="tl_${TIGER_YEAR}_us_${TIGER_GEOGRAPHY}"
SHP_PATH="${DATA_DIR}/${BASENAME}.shp"

export PGPASSWORD="$DB_PASSWORD"

if [ ! -f "$SHP_PATH" ]; then
  echo "Missing shapefile: $SHP_PATH"
  echo "Run download_tiger_data.sh with TIGER_GEOGRAPHY=${TIGER_GEOGRAPHY} first."
  exit 1
fi

echo "Waiting for Postgres at ${DB_HOST}:${DB_PORT}..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; do
  sleep 1
done

echo "Ensuring PostGIS extension exists..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c \
  "CREATE EXTENSION IF NOT EXISTS postgis;"

table_exists="$(
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
  "SELECT to_regclass('${TABLE_NAME}');"
)"

if [ "$table_exists" = "$TABLE_NAME" ]; then
  echo "Table ${TABLE_NAME} already exists; skipping import."
  exit 0
fi

echo "Importing ${SHP_PATH} into ${TABLE_NAME}..."
shp2pgsql -I -s 4269:4326 "$SHP_PATH" "$TABLE_NAME" | \
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1

echo "${TIGER_GEOGRAPHY^} import complete."
