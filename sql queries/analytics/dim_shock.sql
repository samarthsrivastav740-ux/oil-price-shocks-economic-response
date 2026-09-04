-- Create dim_shock
CREATE TABLE analytics.dim_shock (
    shock_key SERIAL PRIMARY KEY,

    year INTEGER NOT NULL,
    month INTEGER NOT NULL,

    brent_return_pct NUMERIC(12, 4) NOT NULL,
    wti_return_pct NUMERIC(12, 4) NOT NULL,

    shock_direction VARCHAR(10) NOT NULL,
    shock_severity VARCHAR(10) NOT NULL,

    is_shock BOOLEAN NOT NULL,

    UNIQUE (year, month),

    CHECK (month BETWEEN 1 AND 12),

    CHECK (shock_direction IN ('Increase', 'Decrease', 'Neutral')),

    CHECK (shock_severity IN ('Normal', 'Moderate', 'Severe'))
);


-- Insert values into dim_shock
INSERT INTO analytics.dim_shock (
    year,
    month,
    brent_return_pct,
    wti_return_pct,
    shock_direction,
    shock_severity,
    is_shock
)

SELECT
    year,
    month,
    brent_return_pct,
    wti_return_pct,

    CASE
        WHEN brent_return_pct > 0 THEN 'Increase'
        WHEN brent_return_pct < 0 THEN 'Decrease'
        ELSE 'Neutral'
    END AS shock_direction,

    CASE
        -- Positive movements
        WHEN brent_return_pct > 13.45075
            THEN 'Severe'

        WHEN brent_return_pct > 10.4635
            THEN 'Moderate'

        -- Negative movements
        WHEN brent_return_pct < -14.4100
            THEN 'Severe'

        WHEN brent_return_pct < -10.2562
            THEN 'Moderate'

        -- Everything else
        ELSE 'Normal'
    END AS shock_severity,

    CASE
        WHEN brent_return_pct > 10.4635
          OR brent_return_pct < -10.2562
            THEN TRUE
        ELSE FALSE
    END AS is_shock

FROM analytics.fact_oil_monthly
WHERE brent_return_pct IS NOT NULL;


-- Validating dim_shock
SELECT *
FROM analytics.dim_shock
ORDER BY year, month
LIMIT 15;


SELECT
    shock_direction,
    shock_severity,
    is_shock,
    COUNT(*) AS months
FROM analytics.dim_shock
GROUP BY
    shock_direction,
    shock_severity,
    is_shock
ORDER BY
    shock_direction,
    shock_severity;


SELECT
    COUNT(*) AS total_months,
    COUNT(*) FILTER (WHERE is_shock = TRUE) AS shock_months,
    COUNT(*) FILTER (WHERE is_shock = FALSE) AS normal_months,
    COUNT(*) FILTER (WHERE shock_severity = 'Moderate') AS moderate_months,
    COUNT(*) FILTER (WHERE shock_severity = 'Severe') AS severe_months
FROM analytics.dim_shock;


SELECT
    year,
    month,
    brent_return_pct,
    wti_return_pct,
    shock_direction,
    shock_severity
FROM analytics.dim_shock
WHERE shock_severity = 'Severe'
ORDER BY brent_return_pct;