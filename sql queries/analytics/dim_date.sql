-- Creating dim_date
CREATE TABLE analytics.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INTEGER NOT NULL,
    month_start_date DATE NOT NULL,
    year_start_date DATE NOT NULL
);


-- Insert Data
INSERT INTO analytics.dim_date (
    date_key,
    full_date,
    year,
    month,
    month_name,
    quarter,
    month_start_date,
    year_start_date
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d AS full_date,
    EXTRACT(YEAR FROM d)::INTEGER AS year,
    EXTRACT(MONTH FROM d)::INTEGER AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    DATE_TRUNC('month', d)::DATE AS month_start_date,
    DATE_TRUNC('year', d)::DATE AS year_start_date
FROM GENERATE_SERIES(
    '2000-01-01'::DATE,
    '2025-12-31'::DATE,
    '1 day'::INTERVAL
) AS d;


-- Validate
SELECT *
FROM analytics.dim_date
ORDER BY full_date
LIMIT 10;


SELECT *
FROM analytics.dim_date
ORDER BY full_date DESC
LIMIT 10;


SELECT
    COUNT(*) AS total_dates,
    MIN(full_date) AS first_date,
    MAX(full_date) AS last_date
FROM analytics.dim_date;