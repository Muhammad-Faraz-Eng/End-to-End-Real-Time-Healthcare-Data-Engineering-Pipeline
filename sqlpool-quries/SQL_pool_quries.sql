/*=========================================================
    🔐 CREATE MASTER KEY (ONCE PER DATABASE)
=========================================================*/
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPasswordHere123!';


/*=========================================================
    🔗 CREATE DATABASE SCOPED CREDENTIAL USING MANAGED IDENTITY
=========================================================*/
IF NOT EXISTS (
    SELECT * FROM sys.database_scoped_credentials 
    WHERE name = 'storage_credential'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL storage_credential
    WITH IDENTITY = 'Managed Identity';
END;


/*=========================================================
    🧱 DEFINE FILE FORMAT (PARQUET)
=========================================================*/
IF NOT EXISTS (
    SELECT * FROM sys.external_file_formats 
    WHERE name = 'ParquetFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFileFormat
    WITH (FORMAT_TYPE = PARQUET);
END;


/*=========================================================
    ⚡ QUERY USING OPENROWSET (NO EXTERNAL DATA SOURCE)
=========================================================*/

-- 🟤 BRONZE LAYER (RAW DATA)
SELECT TOP 10 *
FROM OPENROWSET(
    BULK 'https://yourstorageaccountname.dfs.core.windows.net/bronze/raw_data/*.json',
    FORMAT='CSV',  -- or 'PARQUET', 'JSON' depending on your format
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A'
) AS [bronze_data];


-- ⚪ SILVER LAYER (CLEANED DATA)
SELECT TOP 10 *
FROM OPENROWSET(
    BULK 'https://yourstorageaccountname.dfs.core.windows.net/silver/cleaned_data/*.parquet',
    FORMAT='PARQUET'
) AS [silver_data];


-- 🟡 GOLD LAYER (CURATED DATA)
SELECT TOP 10 *
FROM OPENROWSET(
    BULK 'https://yourstorageaccountname.dfs.core.windows.net/gold/fact_patient_flow/*.parquet',
    FORMAT='PARQUET'
) AS [gold_data];


-- You can directly filter or join data across layers
SELECT 
    g.patient_sk,
    g.department_sk,
    g.length_of_stay_hours,
    d.department
FROM OPENROWSET(
    BULK 'https://yourstorageaccountname.dfs.core.windows.net/gold/fact_patient_flow/*.parquet',
    FORMAT='PARQUET'
) AS g
INNER JOIN OPENROWSET(
    BULK 'https://yourstorageaccountname.dfs.core.windows.net/gold/dim_department/*.parquet',
    FORMAT='PARQUET'
) AS d
ON g.department_sk = d.surrogate_key;
