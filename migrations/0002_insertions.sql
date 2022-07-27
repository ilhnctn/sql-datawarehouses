-- -- WIP: Generate dummy PR data by variable input 
-- CREATE OR REPLACE FUNCTION insert_random_data_to_table(
--     table_name VARCHAR,
--     start_date DATE DEFAULT '2022-07-07',
--     end_date DATE DEFAULT '2022-07-22',
--     pull_req_interval INTERVAL DEFAULT '100 minute') RETURNS VOID
--     AS $FUNCTION$
--     BEGIN

--     EXECUTE 'WITH payload_data AS ( ' ||
--         'SELECT ( ' ||
--                '{ "username": "user_' || i::text || '"' ||
--                ', "type": "PullRequestEvent"' ||
--                ', "description": "user_' || i::text || '"' ||
--                ', "blablabla":'' || trunc(1000 * random() + 1) || '' }'')::JSONB AS payload FROM generate_series(0, 10) i)' ||
--     'INSERT INTO ' || table_name || ' (repo_name, commit_datetime, description, payload) ' ||
--     'SELECT  ''grafana/grafana'' as repo_name, ' ||
--               'commit_datetime, ' ||
--               'rand description for ' || i::text AS description, ||
--               'payload FROM payload_data, ' ||
--               'generate_series(0, 10) i, ' ||
--               'generate_series(' || start_date || '::TIMESTAMP ,'|| end_date || '::TIMESTAMP , ' || pull_req_interval || '::INTERVAL) as commit_datetime;';

-- END;
-- $FUNCTION$
-- LANGUAGE 'plpgsql';

-- Since the function above didn't run through, use hardcoded values as below.

WITH payload_data AS(
    SELECT (
           '{ "username": "user_' || i::text || '"' ||
           ', "type": "PullRequestEvent"' ||
           ', "description": "rand description for ' || i::text || '"' ||
           ', "blablabla":' || trunc(1000 * random() + 1) || ' }')::JSONB AS payload
         FROM generate_series(0, 100) i)
INSERT INTO data_table_normal (repo_name, commit_datetime, description, payload)
        SELECT  'grafana/grafana' as repo_name,
                commit_datetime, 
                'rand description for ' || i::text AS description,
                payload from payload_data, 
                generate_series(0, 100) i,
                generate_series(
                    '2022-07-07'::TIMESTAMP ,
                    '2022-07-22'::TIMESTAMP , '120 minute'::INTERVAL) as commit_datetime;


WITH payload_data AS(
    SELECT (
           '{ "username": "user_' || i::text || '"' ||
           ', "type": "PullRequestEvent"' ||
           ', "description": "user_' || i::text || '"' ||
           ', "blablabla":' || trunc(1000 * random() + 1) || ' }')::JSONB AS payload
         FROM generate_series(0, 100) i)
INSERT INTO data_table_columnar (repo_name, commit_datetime, description, payload)
        SELECT  'grafana/grafana' as repo_name, 
                commit_datetime, 
                'rand description for ' || i::text AS description,
                payload from payload_data, 
                generate_series(0, 100) i,
                generate_series(
                    '2022-07-07'::TIMESTAMP ,
                    '2022-07-22'::TIMESTAMP , '120 minute'::INTERVAL) as commit_datetime;
