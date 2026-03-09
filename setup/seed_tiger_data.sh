#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"${SCRIPT_DIR}/ensure_tiger_counties.sh"
"${SCRIPT_DIR}/import_tiger_counties.sh"