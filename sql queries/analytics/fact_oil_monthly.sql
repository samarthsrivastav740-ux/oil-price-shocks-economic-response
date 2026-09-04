-- Creating fact_oil_monthly
CREATE TABLE analytics.fact_oil_monthly (
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,

    avg_brent_price NUMERIC(12, 4),
    avg_wti_price NUMERIC(12, 4),

    brent_return_pct NUMERIC(12, 4),
    wti_return_pct NUMERIC(12, 4),

    brent_volatility NUMERIC(12, 4),
    wti_volatility NUMERIC(12, 4),

    brent_wti_spread NUMERIC(12, 4),

    PRIMARY KEY (year, month),

    CHECK (month BETWEEN 1 AND 12)
);


-- Validation before inserting values in fact_oil_monthly

-- For monthly avg brent price
SELECT
    EXTRACT(YEAR FROM date)::INTEGER AS year,
    EXTRACT(MONTH FROM date)::INTEGER AS month,
    AVG(value) AS avg_brent_price
FROM staging.stg_fred_brent_crude_price
GROUP BY 1, 2
ORDER BY 1, 2;

-- For monthly avg wti price
SELECT
    EXTRACT(YEAR FROM date)::INTEGER AS year,
    EXTRACT(MONTH FROM date)::INTEGER AS month,
    AVG(value) AS avg_wti_price
FROM staging.stg_fred_wti_crude_price
GROUP BY 1, 2
ORDER BY 1, 2;


-- Insert values into fact_oil_monthly

INSERT INTO analytics.fact_oil_monthly (
    year,
    month,
    avg_brent_price,
    avg_wti_price,
    brent_return_pct,
    wti_return_pct,
    brent_volatility,
    wti_volatility,
    brent_wti_spread
)

WITH brent_monthly AS (
    SELECT
        EXTRACT(YEAR FROM date)::INTEGER AS year,
        EXTRACT(MONTH FROM date)::INTEGER AS month,
        AVG(value) AS avg_brent_price,
        STDDEV_SAMP(value) AS brent_volatility
    FROM staging.stg_fred_brent_crude_price
    GROUP BY 1, 2
),

wti_monthly AS (
    SELECT
        EXTRACT(YEAR FROM date)::INTEGER AS year,
        EXTRACT(MONTH FROM date)::INTEGER AS month,
        AVG(value) AS avg_wti_price,
        STDDEV_SAMP(value) AS wti_volatility
    FROM staging.stg_fred_wti_crude_price
    GROUP BY 1, 2
),

monthly_combined AS (
    SELECT
        b.year,
        b.month,
        b.avg_brent_price,
        w.avg_wti_price,
        b.brent_volatility,
        w.wti_volatility
    FROM brent_monthly b
    INNER JOIN wti_monthly w
        ON b.year = w.year
        AND b.month = w.month
),

with_previous AS (
    SELECT
        *,
        LAG(avg_brent_price) OVER (
            ORDER BY year, month
        ) AS previous_brent_price,

        LAG(avg_wti_price) OVER (
            ORDER BY year, month
        ) AS previous_wti_price

    FROM monthly_combined
)

SELECT
    year,
    month,

    avg_brent_price,
    avg_wti_price,

    (
        (avg_brent_price / previous_brent_price) - 1
    ) * 100 AS brent_return_pct,

    (
        (avg_wti_price / previous_wti_price) - 1
    ) * 100 AS wti_return_pct,

    brent_volatility,
    wti_volatility,

    avg_brent_price - avg_wti_price AS brent_wti_spread

FROM with_previous
ORDER BY year, month;


-- Validate fact_oil_monthly
SELECT *
FROM analytics.fact_oil_monthly
ORDER BY year, month 
LIMIT 15;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (year, month)) AS unique_months,
    COUNT(brent_return_pct) AS brent_returns,
    COUNT(wti_return_pct) AS wti_returns
FROM analytics.fact_oil_monthly;