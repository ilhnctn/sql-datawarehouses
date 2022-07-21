-- Normal Table
CREATE TABLE IF NOT EXISTS data_table_normal(
    repo_name text not null, 
    commit_datetime timestamp not null, 
    description text, 
    payload jsonb);

-- Columnar table with same structure & data points to normal table. To be used for comparison/benchmarking.
CREATE TABLE IF NOT EXISTS data_table_columnar(
    repo_name text not null, 
    commit_datetime timestamp not null, 
    description text, 
    payload jsonb) USING columnar;
