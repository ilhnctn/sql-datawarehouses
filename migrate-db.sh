#!/bin/bash
set -e

# Default data source is set to githib
data_source=${DATA_SOURCE_NAME:-github}

# if [ -z $data_source ]; then
#     echo "Please supply a data_source to be able to proceed.\n"
#     exit 1
# fi


export PGPASSWORD=$POSTGRES_PASSWORD
# POSTGRES="psql -q -v ON_ERROR_STOP=1 -h $DB_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB"
# echo "Running migration named: $migration on: postgresql://${POSTGRES_USER}:${PGPASSWORD}@${DB_HOST}/${POSTGRES_DB}:${POSTGRES_PORT} db."

# echo
# echo "command is $POSTGRES and PGPASSWORD is $PGPASSWORD"
# echo

# RETRIES=15
# until ${POSTGRES} -c "SELECT version()" &>/dev/null; do
#   if [[ $RETRIES -eq 0 ]]; then
#     echo "Postgres server is still not ready!"
#     exit 1
#   fi
#   echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
#   sleep 2
# done
# echo "Postgres server is ready!"

migrations_path=${MIGRATIONS_PATH:-"./migrations"}

ls -la
echo "migrations_path is ${migrations}"

migrations=$(ls ${migrations_path} | sort -n)

for migration in $migrations; do
    echo "Running migration named: $migration on: postgresql://${POSTGRES_USER}:${PGPASSWORD}@${DB_HOST}/${POSTGRES_DB}:${POSTGRES_PORT} db."
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
