#!/usr/bin/env bash
set -Eeuo pipefail

: "${AWS_REGION:?Set AWS_REGION first}"
: "${BACKUP_BUCKET:?Set BACKUP_BUCKET first}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$ROOT_DIR/backups"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
PREFIX="dr-demo/$TIMESTAMP"

for file in app-state.json release-info.json; do
  test -s "$BACKUP_DIR/$file" || {
    echo "ERROR: Missing or empty file: $BACKUP_DIR/$file"
    exit 1
  }
done

aws s3 cp \
  "$BACKUP_DIR/app-state.json" \
  "s3://$BACKUP_BUCKET/$PREFIX/app-state.json" \
  --region "$AWS_REGION"

aws s3 cp \
  "$BACKUP_DIR/release-info.json" \
  "s3://$BACKUP_BUCKET/$PREFIX/release-info.json" \
  --region "$AWS_REGION"

echo "Backup uploaded to s3://$BACKUP_BUCKET/$PREFIX/"
echo "$PREFIX" > "$ROOT_DIR/backups/latest-prefix.txt"