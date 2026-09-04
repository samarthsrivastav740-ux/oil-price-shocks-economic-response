-- Create fact_country_year

CREATE TABLE analytics.fact_country_year (
    country_key INTEGER NOT NULL,
    year INTEGER NOT NULL,

    energy_imports NUMERIC,
    energy_use NUMERIC,
    exports NUMERIC,
    gdp_current_usd NUMERIC,
    gdp_growth NUMERIC,
    gdp_per_capita NUMERIC,
    imports NUMERIC,
    inflation NUMERIC,

    PRIMARY KEY (country_key, year),

    FOREIGN KEY (country_key)
        REFERENCES analytics.dim_country(country_key)
);


-- Insert values in fact_country_year
INSERT INTO analytics.fact_country_year (
    country_key,
    year,
    energy_imports,
    energy_use,
    exports,
    gdp_current_usd,
    gdp_growth,
    gdp_per_capita,
    imports,
    inflation
)

SELECT
    c.country_key,
    ei.year,

    ei.value AS energy_imports,
    eu.value AS energy_use,
    e.value AS exports,
    gdp.value AS gdp_current_usd,
    gg.value AS gdp_growth,
    gpc.value AS gdp_per_capita,
    i.value AS imports,
    inf.value AS inflation

FROM staging.stg_wb_energy_imports ei

JOIN analytics.dim_country c
    ON ei.country_code = c.country_code

JOIN staging.stg_wb_energy_use eu
    ON ei.country_code = eu.country_code
   AND ei.year = eu.year

JOIN staging.stg_wb_exports e
    ON ei.country_code = e.country_code
   AND ei.year = e.year

JOIN staging.stg_wb_gdp gdp
    ON ei.country_code = gdp.country_code
   AND ei.year = gdp.year

JOIN staging.stg_wb_gdp_growth gg
    ON ei.country_code = gg.country_code
   AND ei.year = gg.year

JOIN staging.stg_wb_gdp_per_capita gpc
    ON ei.country_code = gpc.country_code
   AND ei.year = gpc.year

JOIN staging.stg_wb_imports i
    ON ei.country_code = i.country_code
   AND ei.year = i.year

JOIN staging.stg_wb_inflation inf
    ON ei.country_code = inf.country_code
   AND ei.year = inf.year;


-- Validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT country_key) AS countries,
    COUNT(DISTINCT year) AS years,
    COUNT(DISTINCT (country_key, year)) AS unique_country_years
FROM analytics.fact_country_year;


SELECT
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    COUNT(*) FILTER (WHERE energy_imports IS NULL) AS missing_energy_imports,
    COUNT(*) FILTER (WHERE energy_use IS NULL) AS missing_energy_use,
    COUNT(*) FILTER (WHERE exports IS NULL) AS missing_exports,
    COUNT(*) FILTER (WHERE gdp_current_usd IS NULL) AS missing_gdp,
    COUNT(*) FILTER (WHERE gdp_growth IS NULL) AS missing_gdp_growth,
    COUNT(*) FILTER (WHERE gdp_per_capita IS NULL) AS missing_gdp_per_capita,
    COUNT(*) FILTER (WHERE imports IS NULL) AS missing_imports,
    COUNT(*) FILTER (WHERE inflation IS NULL) AS missing_inflation
FROM analytics.fact_country_year;


SELECT *
FROM analytics.fact_country_year;