#!/usr/bin/env bash
set -Eeuo pipefail

: "${AWS_REGION:?Set AWS_REGION first}"
: "${BACKUP_BUCKET:?Set BACKUP_BUCKET first}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESTORE_DIR="$ROOT_DIR/recovery"
PREFIX_FILE="$ROOT_DIR/backups/latest-prefix.txt"

if [[ $# -ge 1 ]]; then
  PREFIX="$1"
else
  test -s "$PREFIX_FILE" || {
    echo "ERROR: No backup prefix found. Pass the backup prefix as an argument."
    exit 1
  }
  PREFIX="$(cat "$PREFIX_FILE")"
fi

[[ "$PREFIX" =~ ^dr-demo/[A-Za-z0-9T_-]+$ ]] || {
  echo "ERROR: Invalid backup prefix."
  exit 1
}

mkdir -p "$RESTORE_DIR"

aws s3 cp \
  "s3://$BACKUP_BUCKET/$PREFIX/app-state.json" \
  "$RESTORE_DIR/app-state.json" \
  --region "$AWS_REGION"

aws s3 cp \
  "s3://$BACKUP_BUCKET/$PREFIX/release-info.json" \
  "$RESTORE_DIR/release-info.json" \
  --region "$AWS_REGION"

python3 -m json.tool "$RESTORE_DIR/app-state.json" >/dev/null
python3 -m json.tool "$RESTORE_DIR/release-info.json" >/dev/null

echo "Restore downloaded and JSON validation passed."
echo "Restored files are in: $RESTORE_DIR"