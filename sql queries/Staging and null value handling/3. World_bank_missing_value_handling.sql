-- ============================================================
-- WORLD BANK STAGING DATA CLEANING
-- ============================================================
-- Final analytical period: 2001-2022
--
-- Reason:
-- 2000 is excluded because oil return calculations begin in 2001.
-- 2023-2025 have incomplete World Bank coverage.
-- Within 2001-2022, only UAE inflation has missing values.
--
-- Source tables remain unchanged.
-- All cleaning is performed in the staging layer.
-- ============================================================


-- ============================================================
-- 1. COPY SOURCE TABLES INTO STAGING
-- ============================================================

DROP TABLE IF EXISTS staging.stg_wb_energy_imports;

CREATE TABLE staging.stg_wb_energy_imports AS
SELECT *
FROM source.wb_energy_imports;


DROP TABLE IF EXISTS staging.stg_wb_energy_use;

CREATE TABLE staging.stg_wb_energy_use AS
SELECT *
FROM source.wb_energy_use;


DROP TABLE IF EXISTS staging.stg_wb_exports;

CREATE TABLE staging.stg_wb_exports AS
SELECT *
FROM source.wb_exports;


DROP TABLE IF EXISTS staging.stg_wb_gdp;

CREATE TABLE staging.stg_wb_gdp AS
SELECT *
FROM source.wb_gdp;


DROP TABLE IF EXISTS staging.stg_wb_gdp_growth;

CREATE TABLE staging.stg_wb_gdp_growth AS
SELECT *
FROM source.wb_gdp_growth;


DROP TABLE IF EXISTS staging.stg_wb_gdp_per_capita;

CREATE TABLE staging.stg_wb_gdp_per_capita AS
SELECT *
FROM source.wb_gdp_per_capita;


DROP TABLE IF EXISTS staging.stg_wb_imports;

CREATE TABLE staging.stg_wb_imports AS
SELECT *
FROM source.wb_imports;


DROP TABLE IF EXISTS staging.stg_wb_inflation;

CREATE TABLE staging.stg_wb_inflation AS
SELECT *
FROM source.wb_inflation;


-- ============================================================
-- 2. KEEP ANALYTICAL PERIOD: 2001-2022
-- ============================================================

DELETE FROM staging.stg_wb_energy_imports
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_energy_use
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_exports
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_gdp
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_gdp_growth
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_gdp_per_capita
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_imports
WHERE year NOT BETWEEN 2001 AND 2022;

DELETE FROM staging.stg_wb_inflation
WHERE year NOT BETWEEN 2001 AND 2022;


-- ============================================================
-- 3. FILL UAE INFLATION VALUES
-- ============================================================
-- UAE (ARE) inflation values for 2001-2007 were missing
-- from the original World Bank extract.
--
-- Verified values:
-- 2001 = 2.80
-- 2002 = 2.92
-- 2003 = 3.12
-- 2004 = 5.04
-- 2005 = 6.20
-- 2006 = 9.29
-- 2007 = 11.13
--
-- Source data is not modified.
-- ============================================================

UPDATE staging.stg_wb_inflation
SET value = CASE year
    WHEN 2001 THEN 2.80
    WHEN 2002 THEN 2.92
    WHEN 2003 THEN 3.12
    WHEN 2004 THEN 5.04
    WHEN 2005 THEN 6.20
    WHEN 2006 THEN 9.29
    WHEN 2007 THEN 11.13
END
WHERE country_code = 'ARE'
  AND year BETWEEN 2001 AND 2007;


-- ============================================================
-- 4. ROUND INFLATION TO 2 DECIMAL PLACES
-- ============================================================

ALTER TABLE staging.stg_wb_inflation
ALTER COLUMN value TYPE numeric(10,2)
USING ROUND(value::numeric, 2);


-- ============================================================
-- 5. VALIDATE UAE INFLATION
-- ============================================================

SELECT
    country_code,
    year,
    value
FROM staging.stg_wb_inflation
WHERE country_code = 'ARE'
  AND year BETWEEN 2001 AND 2007
ORDER BY year;


-- ============================================================
-- 6. VALIDATE ALL WORLD BANK TABLES
-- ============================================================

SELECT
    'energy_imports' AS indicator,
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT country_code) AS countries,
    COUNT(DISTINCT (country_code, year)) AS country_years,
    COUNT(*) FILTER (WHERE value IS NULL) AS missing_values
FROM staging.stg_wb_energy_imports

UNION ALL

SELECT
    'energy_use',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_energy_use

UNION ALL

SELECT
    'exports',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_exports

UNION ALL

SELECT
    'gdp',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_gdp

UNION ALL

SELECT
    'gdp_growth',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_gdp_growth

UNION ALL

SELECT
    'gdp_per_capita',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_gdp_per_capita

UNION ALL

SELECT
    'imports',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_imports

UNION ALL

SELECT
    'inflation',
    MIN(year),
    MAX(year),
    COUNT(*),
    COUNT(DISTINCT country_code),
    COUNT(DISTINCT (country_code, year)),
    COUNT(*) FILTER (WHERE value IS NULL)
FROM staging.stg_wb_inflation

ORDER BY indicator;


-- ============================================================
-- 7. CHECK EXPECTED COMPLETE PANEL
-- ============================================================
-- 14 countries × 22 years = 308 rows per indicator

SELECT
    'energy_imports' AS indicator,
    COUNT(*) AS total_rows
FROM staging.stg_wb_energy_imports

UNION ALL

SELECT
    'energy_use',
    COUNT(*)
FROM staging.stg_wb_energy_use

UNION ALL

SELECT
    'exports',
    COUNT(*)
FROM staging.stg_wb_exports

UNION ALL

SELECT
    'gdp',
    COUNT(*)
FROM staging.stg_wb_gdp

UNION ALL

SELECT
    'gdp_growth',
    COUNT(*)
FROM staging.stg_wb_gdp_growth

UNION ALL

SELECT
    'gdp_per_capita',
    COUNT(*)
FROM staging.stg_wb_gdp_per_capita

UNION ALL

SELECT
    'imports',
    COUNT(*)
FROM staging.stg_wb_imports

UNION ALL

SELECT
    'inflation',
    COUNT(*)
FROM staging.stg_wb_inflation

ORDER BY indicator;


-- ============================================================
-- FINAL EXPECTATION
-- ============================================================
-- Each indicator:
--   Years       : 2001-2022
--   Countries   : 14
--   Rows        : 308
--   Missing     : 0
--
-- Source tables remain unchanged.
-- ============================================================