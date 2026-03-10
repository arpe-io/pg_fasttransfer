


-- Safe version of pg_fasttransfer function with full parameter support
CREATE OR REPLACE FUNCTION xp_RunFastTransfer_secure(
    sourceconnectiontype text DEFAULT NULL,
    sourceconnectstring text DEFAULT NULL,
    sourcedsn text DEFAULT NULL,
    sourceprovider text DEFAULT NULL,
    sourceserver text DEFAULT NULL,
    sourceuser text DEFAULT NULL,
    sourcepassword text DEFAULT NULL,
    sourcetrusted boolean DEFAULT NULL,
    sourcedatabase text DEFAULT NULL,
    sourceschema text DEFAULT NULL,
    sourcetable text DEFAULT NULL,
    query text DEFAULT NULL,
    fileinput text DEFAULT NULL,
    targetconnectiontype text DEFAULT NULL,
    targetconnectstring text DEFAULT NULL,
    targetserver text DEFAULT NULL,
    targetuser text DEFAULT NULL,
    targetpassword text DEFAULT NULL,
    targettrusted boolean DEFAULT NULL,
    targetdatabase text DEFAULT NULL,
    targetschema text DEFAULT NULL,
    targettable text DEFAULT NULL,
    degree integer DEFAULT NULL,
    method text DEFAULT NULL,
    distributekeycolumn text DEFAULT NULL,
    datadrivenquery text DEFAULT NULL,
    loadmode text DEFAULT NULL,
    batchsize integer DEFAULT NULL,
    useworktables boolean DEFAULT NULL,
    runid text DEFAULT NULL,
    settingsfile text DEFAULT NULL,
    mapmethod text DEFAULT NULL,
    license text DEFAULT NULL,
    loglevel text DEFAULT NULL,
    nobanner boolean DEFAULT NULL,
    fasttransfer_path text DEFAULT NULL,
    debug boolean DEFAULT false
)
RETURNS TABLE (
    exit_code integer, 
    output text,
    error_message text,
    total_rows bigint,
    total_columns integer,
    transfer_time_ms bigint,
    total_time_ms bigint    
) AS 'pg_fasttransfer','xp_RunFastTransfer_secure'
LANGUAGE C;

CREATE OR REPLACE FUNCTION pg_fasttransfer_encrypt(password text)
RETURNS text
AS 'pg_fasttransfer', 'pg_fasttransfer_encrypt'
LANGUAGE C STRICT;
