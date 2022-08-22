## Motivation
This repo demonstrates a Data Warehouse implementation on different database setups like Postgresql+Citus Data (columnar), [ClickHouse](https://clickhouse.com/), Google BigQuery.

The main goal is to give a tool replaceable by [Google BigQuery](https://cloud.google.com/bigquery/), which relies on standard SQL with processing enormous amounts of data in an serverless fashion.

## Start Data Layer In Dev Env
Since BigQuery supports Standard SQL queries, every query used in this repo should run directly in BigQuery as well. 

Important Note: Due to an access issue on docker-compose networking, I moved migrations to a separate command.
Ideally docker-compose would spin everything up (currently commented out in compose file)

```bash
# Clone the repo
git clone REPO_NAME && cd repo_dir

# Set environment variables
cp .env.template .env


# Start the environment.
docker-compose up 

# In a separate terminal tab
sh migrate-db.sh
```

Commands above will setup a Postgresql database with Citus extension, which enables distributes Postgresql for scale and prepare some tables with pre-populated data which mimics the [Github dataset](https://cloud.google.com/blog/topics/public-datasets/github-on-bigquery-analyze-all-the-open-source-code) on BigQuery.

For more about BigQuery part, see [this page](./bigquery.md).


Below is the showcase of the size difference between columnar and normal tables. Even though the number of rows and the content are exactly same, size of `data_table_columnar` is 2416kB (2.4MB) while the size of `data_table_normal` is 721MB, which means there is an almost 300 times difference between the formats.
```sh
docker exec -it mbition-dw_db_1 psql -U test_user -d test_db

# or
PGPASSWORD=PleaseChangeThis psql -q -v ON_ERROR_STOP=1 -h localhost -p 5432 -U test_user -d test_db

psql (14.4 (Debian 14.4-1.pgdg110+1))
Type "help" for help.

test_db=# \d
              List of relations
 Schema |        Name         | Type  | Owner 
--------+---------------------+-------+-------
 public | citus_tables        | view  | admin
 public | data_table_columnar | table | admin
 public | data_table_normal   | table | admin
(3 rows)

test_db=# SELECT pg_size_pretty( pg_total_relation_size('data_table_columnar'));
 pg_size_pretty 
----------------
 2416 kB
(1 row)

test_db=# SELECT pg_size_pretty( pg_total_relation_size('data_table_normal'));
 pg_size_pretty 
----------------
 721 MB
(1 row)
```

## Index And Partitioning
Since analytics querries will mainly need to read a big part of data, index usage will not be a wise option, but depending on the use case, table partitioning based on given column(s) can create an enormous impact.

Due to time restrictions I could not showcase these scenarios but I have a lot examples/experiences on Postgresql in general.

Below you can see the query plans for some columns. As you will realize, the reads from columnar table are already filtered from data chunks.

If a date-based partitioning applied, these queries would be much efficient.


```sql
test_db=# EXPLAIN ANALYZE VERBOSE SELECT repo_name from data_table_normal where commit_datetime > '2022-07-15';
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Seq Scan on public.data_table_normal  (cost=0.00..138480.00 rows=1715522 width=16) (actual time=153.574..2753.774 rows=1713768 loops=1)
   Output: repo_name
   Filter: (data_table_normal.commit_datetime > '2022-07-15 00:00:00'::timestamp without time zone)
   Rows Removed by Filter: 1978994
 Planning Time: 0.117 ms
 JIT:
   Functions: 4
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 0.874 ms, Inlining 0.000 ms, Optimization 0.401 ms, Emission 2.627 ms, Total 3.902 ms
 Execution Time: 4984.316 ms
(10 rows)

test_db=# EXPLAIN ANALYZE VERBOSE SELECT repo_name from data_table_columnar where commit_datetime > '2022-07-15';
                                                                      QUERY PLAN                                                            
           
--------------------------------------------------------------------------------------------------------------------------------------------
-----------
 Custom Scan (ColumnarScan) on public.data_table_columnar  (cost=0.00..48.96 rows=1230921 width=32) (actual time=9.631..2436.225 rows=171376
8 loops=1)
   Output: repo_name
   Filter: (data_table_columnar.commit_datetime > '2022-07-15 00:00:00'::timestamp without time zone)
   Rows Removed by Filter: 18994
   Columnar Projected Columns: repo_name, commit_datetime
   Columnar Chunk Group Filters: (commit_datetime > '2022-07-15 00:00:00'::timestamp without time zone)
   Columnar Chunk Groups Removed by Filter: 196
 Planning Time: 1.849 ms
 Execution Time: 4652.129 ms
(9 rows)

test_db=# 

```


## Missing Parts & TODOs
- [ ] Add ClickHouse example
- [ ] Use Grafana for visualising Pull Requests over time 
- [ ] Use table partitioning to increase performance (based on use cases)
- [ ] Add data ingestion examples (Both local and BigQuery)
- [ ] Prepare release/deployment (IaC) scripts 
- [ ] Plan a development Pipeline (CI/CD ? Not sure yet)
- [ ] Use parametrizible sql function for initial data preparation (`insert_random_data_to_table` doesn't work right now)
