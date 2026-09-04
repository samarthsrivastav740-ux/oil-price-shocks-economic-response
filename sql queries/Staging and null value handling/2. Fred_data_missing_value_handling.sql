-- ============================================================
-- FRED MISSING-DATE ANALYSIS
-- ============================================================
-- Purpose:
-- Investigate missing Brent and WTI observations in the staging
-- layer before deciding how they should be treated analytically.
-- ============================================================


-- ============================================================
-- 1. FRED_BRENT_CRUDE_PRICE
-- ============================================================


-- Check Brent table structure and data types.
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_fred_brent_crude_price'
ORDER BY ordinal_position;


-- Check Brent row count and missing price values.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE value IS NULL) AS missing_values,
    COUNT(value) AS available_values
FROM staging.stg_fred_brent_crude_price;


-- Classify missing Brent observations by day of week.
SELECT
    CASE
        WHEN EXTRACT(ISODOW FROM date) IN (6, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS missing_count
FROM staging.stg_fred_brent_crude_price
WHERE value IS NULL
GROUP BY 1
ORDER BY 1;


-- List all missing Brent dates for holiday/non-trading-day review.
SELECT
    date,
    TO_CHAR(date, 'Day') AS day_name
FROM staging.stg_fred_brent_crude_price
WHERE value IS NULL
ORDER BY date;


-- Summarize missing Brent observations by year.
SELECT
    EXTRACT(YEAR FROM date)::INT AS year,
    COUNT(*) AS missing_days
FROM staging.stg_fred_brent_crude_price
WHERE value IS NULL
GROUP BY 1
ORDER BY 1;


-- Remove unavailable Brent observations from staging.
DELETE FROM staging.stg_fred_brent_crude_price
WHERE value IS NULL;

-- Verify that staging Brent contains no missing prices.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE value IS NULL) AS missing_values
FROM staging.stg_fred_brent_crude_price;


-- ============================================================
-- 2. FRED_WTI_CRUDE_PRICE
-- ============================================================


-- Check WTI table structure and data types.
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_fred_wti_crude_price'
ORDER BY ordinal_position;


-- Check WTI row count and missing price values.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE value IS NULL) AS missing_values,
    COUNT(value) AS available_values
FROM staging.stg_fred_wti_crude_price;


-- Classify missing WTI observations by day of week.
SELECT
    CASE
        WHEN EXTRACT(ISODOW FROM date) IN (6, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS missing_count
FROM staging.stg_fred_wti_crude_price
WHERE value IS NULL
GROUP BY 1
ORDER BY 1;


-- List all missing WTI dates for holiday/non-trading-day review.
SELECT
    date,
    TO_CHAR(date, 'Day') AS day_name
FROM staging.stg_fred_wti_crude_price
WHERE value IS NULL
ORDER BY date;


-- Remove unavailable WTI observations from staging.
DELETE FROM staging.stg_fred_wti_crude_price
WHERE value IS NULL;


-- Verify that staging WTI contains no missing prices.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE value IS NULL) AS missing_values
FROM staging.stg_fred_wti_crude_price;


-- ============================================================
-- Note:
-- The removed dates were dates for which FRED had no oil-price
-- observation. I preserved the missing values in the source 
-- layer, then excluded those unavailable dates from the staging 
-- layer rather than inventing or forward-filling prices.
-- ============================================================
