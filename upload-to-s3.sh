#!/usr/bin/env bash
# Post-backup hook: syncs /backups to S3 using the EC2 instance role.
# The hook system calls this script with one of: error | pre-backup | post-backup
set -euo pipefail

HOOK_TYPE="${1:-}"

# Only run on successful backup completion
if [ "${HOOK_TYPE}" != "post-backup" ]; then
  exit 0
fi

if [ -z "${S3_BACKUP_PATH:-}" ]; then
  echo "[s3-upload] S3_BACKUP_PATH is not set - skipping upload."
  exit 0
fi

echo "[s3-upload] Syncing /backups -> ${S3_BACKUP_PATH} ..."
aws s3 sync /backups "${S3_BACKUP_PATH}" \
  --storage-class STANDARD_IA \
  --exclude "last/*" \
  --exclude "*-latest.sql.gz" \
  --only-show-errors

echo "[s3-upload] Done."
