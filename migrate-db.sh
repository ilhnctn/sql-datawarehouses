#!/bin/bash
set -e

## Remove this block once docker-compose issue fixed
POSTGRES_DB=${POSTGRES_DB_NAME:-test_db}
POSTGRES_USER=${POSTGRES_DB_USER:-test_user}
POSTGRES_PORT=${POSTGRES_DB_PORT:-5432}
POSTGRES_PASSWORD=${POSTGRES_DB_PASSWORD:-PleaseChangeThis}
DB_HOST=${DB_HOST:-localhost}

# Default data source is set to githib
data_source=${DATA_SOURCE_NAME:-github}

if [ -z $data_source ]; then
    echo "Please supply a data_source to be able to proceed."
    exit 1
fi

export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES="psql -q -v ON_ERROR_STOP=1 -h $DB_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB"

echo
echo "command is $POSTGRES and PG-PASSWORD is $PGPASSWORD"
echo

RETRIES=15
until ${POSTGRES} -c "SELECT version()" &>/dev/null; do
  if [[ $RETRIES -eq 0 ]]; then
    echo "Postgres server is still not ready!"
    exit 1
  fi
  echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
  sleep 2
done
echo "Postgres server is ready!"

migrations_path=${MIGRATIONS_PATH:-"./migrations"}

ls -la
echo "migrations_path is ${migrations}"

migrations=$(ls ${migrations_path} | sort -n)

for migration in $migrations; do
    echo "Running migration named: $migration on: postgresql://${POSTGRES_USER}:${PGPASSWORD}@${DB_HOST}:${POSTGRES_PORT}/${POSTGRES_DB} db."
    migrate_cmd="psql \
                -q \
                ON_ERROR_STOP=1 \
                -f $migrations_path/$migration \
                -h $DB_HOST \
                -p $POSTGRES_PORT \
                -U $POSTGRES_USER \
                -d $POSTGRES_DB
                "
    ${migrate_cmd}

done
