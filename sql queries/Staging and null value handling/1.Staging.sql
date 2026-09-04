-- Copying source data into staging schema
CREATE TABLE staging.stg_fred_brent_crude_price AS
SELECT *
FROM source.fred_brent_crude_price;

CREATE TABLE staging.stg_fred_wti_crude_price AS
SELECT *
FROM source.fred_wti_crude_price;

CREATE TABLE staging.stg_wb_energy_imports AS
SELECT *
FROM source.wb_energy_imports;

CREATE TABLE staging.stg_wb_energy_use AS
SELECT *
FROM source.wb_energy_use;

CREATE TABLE staging.stg_wb_exports AS
SELECT *
FROM source.wb_exports;

CREATE TABLE staging.stg_wb_gdp AS
SELECT *
FROM source.wb_gdp;

CREATE TABLE staging.stg_wb_gdp_growth AS
SELECT *
FROM source.wb_gdp_growth;

CREATE TABLE staging.stg_wb_gdp_per_capita AS
SELECT *
FROM source.wb_gdp_per_capita;

CREATE TABLE staging.stg_wb_imports AS
SELECT *
FROM source.wb_imports;

CREATE TABLE staging.stg_wb_inflation AS
SELECT *
FROM source.wb_inflation;

-- ============================================================
-- STANDARDIZE SOURCE TABLES
-- ============================================================

-- ============================================================
-- FRED TABLES
-- ============================================================

ALTER TABLE staging.stg_fred_brent_crude_price
    ALTER COLUMN date TYPE DATE
        USING date::DATE,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;


ALTER TABLE staging.stg_fred_wti_crude_price
    ALTER COLUMN date TYPE DATE
        USING date::DATE,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;

-- ============================================================
-- WORLD BANK
-- ============================================================

ALTER TABLE staging.stg_wb_energy_imports
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;


ALTER TABLE staging.stg_wb_energy_use
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;


ALTER TABLE staging.stg_wb_gdp
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;


ALTER TABLE staging.stg_wb_gdp_growth
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;


ALTER TABLE staging.stg_wb_gdp_per_capita
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;


ALTER TABLE staging.stg_wb_imports
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;

ALTER TABLE staging.stg_wb_inflation
    ALTER COLUMN country_code TYPE VARCHAR(3),
    ALTER COLUMN country TYPE VARCHAR(100),
    ALTER COLUMN year TYPE INTEGER
        USING year::INTEGER,
    ALTER COLUMN value TYPE NUMERIC
        USING value::NUMERIC;