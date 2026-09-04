-- Create fact_oil_yearly
CREATE TABLE analytics.fact_oil_yearly (
    year INTEGER PRIMARY KEY,

    avg_brent_price NUMERIC(12, 4),
    avg_wti_price NUMERIC(12, 4),

    brent_return_pct NUMERIC(12, 4),
    wti_return_pct NUMERIC(12, 4),

    brent_volatility NUMERIC(12, 4),
    wti_volatility NUMERIC(12, 4),

    brent_wti_spread NUMERIC(12, 4)
);


-- Insert Values in fact_oil_yearly
INSERT INTO analytics.fact_oil_yearly (
    year,
    avg_brent_price,
    avg_wti_price,
    brent_return_pct,
    wti_return_pct,
    brent_volatility,
    wti_volatility,
    brent_wti_spread
)

WITH yearly_base AS (
    SELECT
        year,
        AVG(avg_brent_price) AS avg_brent_price,
        AVG(avg_wti_price) AS avg_wti_price,
        STDDEV_SAMP(brent_return_pct) AS brent_volatility,
        STDDEV_SAMP(wti_return_pct) AS wti_volatility
    FROM analytics.fact_oil_monthly
    GROUP BY year
),

with_previous AS (
    SELECT
        *,
        LAG(avg_brent_price) OVER (
            ORDER BY year
        ) AS previous_brent_price,

        LAG(avg_wti_price) OVER (
            ORDER BY year
        ) AS previous_wti_price

    FROM yearly_base
)

SELECT
    year,
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
ORDER BY year;


-- Validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT year) AS unique_years,
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM analytics.fact_oil_yearly;


SELECT *
FROM analytics.fact_oil_yearly
ORDER BY year;





