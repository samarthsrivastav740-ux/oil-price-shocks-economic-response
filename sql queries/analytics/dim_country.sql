-- Creating dim_country
CREATE TABLE analytics.dim_country (
    country_key SERIAL PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL
);


-- Insert Data
INSERT INTO analytics.dim_country (
    country_code,
    country_name
)
SELECT DISTINCT
    country_code,
    country
FROM staging.stg_wb_gdp
ORDER BY country_code;


-- Validation
SELECT *
FROM analytics.dim_country
ORDER BY country_key;


SELECT
    COUNT(*) AS country_count,
    COUNT(DISTINCT country_code) AS unique_country_codes
FROM analytics.dim_country;
