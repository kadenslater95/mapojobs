#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-mapojobs}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD:-devpassword}"

TIGER_YEAR="${TIGER_YEAR:-2025}"
DATA_DIR="${DATA_DIR:-./data/tiger_counties}"
BASENAME="tl_${TIGER_YEAR}_us_county"
SHP_PATH="${DATA_DIR}/${BASENAME}.shp"
TABLE_NAME="${TABLE_NAME:-public.us_counties}"

export PGPASSWORD="$DB_PASSWORD"

if [ ! -f "$SHP_PATH" ]; then
  echo "Missing shapefile: $SHP_PATH"
  echo "Run ensure_tiger_counties.sh first."
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

echo "County import complete."