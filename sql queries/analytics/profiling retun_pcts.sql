-- Profiling brent_return_pct and wti_retun_pct for dim_shock

-- For brent
SELECT
    COUNT(brent_return_pct) AS observations,
    MIN(brent_return_pct) AS min_return,
    MAX(brent_return_pct) AS max_return,
    AVG(brent_return_pct) AS mean_return,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY brent_return_pct) AS median_return,
    STDDEV_SAMP(brent_return_pct) AS stddev_return,

    PERCENTILE_CONT(0.01)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p01,

    PERCENTILE_CONT(0.05)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p05,

    PERCENTILE_CONT(0.10)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p10,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p25,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p90,

    PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p95,

    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY brent_return_pct) AS p99

FROM analytics.fact_oil_monthly;

-- For WTI
SELECT
    COUNT(wti_return_pct) AS observations,
    MIN(wti_return_pct) AS min_return,
    MAX(wti_return_pct) AS max_return,
    AVG(wti_return_pct) AS mean_return,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY wti_return_pct) AS median_return,
    STDDEV_SAMP(wti_return_pct) AS stddev_return,

    PERCENTILE_CONT(0.01)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p01,

    PERCENTILE_CONT(0.05)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p05,

    PERCENTILE_CONT(0.10)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p10,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p25,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p90,

    PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p95,

    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY wti_return_pct) AS p99

FROM analytics.fact_oil_monthly;

--============================
SELECT
    year,
    month,
    brent_return_pct,
    wti_return_pct
FROM analytics.fact_oil_monthly
WHERE brent_return_pct IS NOT NULL
ORDER BY brent_return_pct DESC
LIMIT 15;

SELECT
    year,
    month,
    brent_return_pct,
    wti_return_pct
FROM analytics.fact_oil_monthly
WHERE brent_return_pct IS NOT NULL
ORDER BY brent_return_pct ASC
LIMIT 15;