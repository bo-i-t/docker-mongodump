#!/bin/bash

set -e

BACKUP_DIR=/backup

# Command line arg takes precedence over env var to determine db
db=${1:-$MONGO_DB}

timestamp=$(date +%Y%m%d%H%M%S)
dump_dir="${BACKUP_DIR}/${db}_${timestamp}"

mongodump \
  --host=$MONGO_HOST \
  --port=$MONGO_PORT \
  --username=$MONGO_USERNAME \
  --password=$MONGO_PASSWORD \
  --authenticationDatabase=$MONGO_AUTHENTICATION_DATABASE \
  --db=$db \
  --out=$dump_dir
