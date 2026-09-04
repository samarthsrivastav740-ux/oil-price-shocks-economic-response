-- ============================================================
-- Create fact_country_shock
-- Grain: 1 row = 1 country × 1 year
-- ============================================================

DROP TABLE IF EXISTS analytics.fact_country_shock;

CREATE TABLE analytics.fact_country_shock (
    country_key INTEGER NOT NULL,
    year INTEGER NOT NULL,

    -- Oil shock exposure
    total_shock_months INTEGER NOT NULL,
    moderate_increase_months INTEGER NOT NULL,
    moderate_decrease_months INTEGER NOT NULL,
    severe_increase_months INTEGER NOT NULL,
    severe_decrease_months INTEGER NOT NULL,
    shock_month_share NUMERIC(6,2) NOT NULL,

    -- Oil price movement
    annual_brent_return NUMERIC(12,4),
    max_positive_brent_return NUMERIC(12,4),
    max_negative_brent_return NUMERIC(12,4),

    -- Economic indicators
    gdp_current_usd NUMERIC,
    gdp_growth NUMERIC,
    gdp_per_capita NUMERIC,
    inflation NUMERIC,
    energy_imports NUMERIC,
    energy_use NUMERIC,
    imports NUMERIC,
    exports NUMERIC,

    -- Keys
    PRIMARY KEY (country_key, year),

    FOREIGN KEY (country_key)
        REFERENCES analytics.dim_country(country_key)
);

-- Insert values into fact_country_shock
INSERT INTO analytics.fact_country_shock (
    country_key,
    year,

    total_shock_months,
    moderate_increase_months,
    moderate_decrease_months,
    severe_increase_months,
    severe_decrease_months,
    shock_month_share,

    annual_brent_return,
    max_positive_brent_return,
    max_negative_brent_return,

    gdp_current_usd,
    gdp_growth,
    gdp_per_capita,
    inflation,
    energy_imports,
    energy_use,
    imports,
    exports
)
SELECT
    cy.country_key,
    cy.year,

    -- SHOCK EXPOSURE

    COUNT(*) FILTER (
        WHERE s.is_shock = TRUE
    ) AS total_shock_months,

    COUNT(*) FILTER (
        WHERE s.shock_severity = 'Moderate'
          AND s.shock_direction = 'Increase'
    ) AS moderate_increase_months,

    COUNT(*) FILTER (
        WHERE s.shock_severity = 'Moderate'
          AND s.shock_direction = 'Decrease'
    ) AS moderate_decrease_months,

    COUNT(*) FILTER (
        WHERE s.shock_severity = 'Severe'
          AND s.shock_direction = 'Increase'
    ) AS severe_increase_months,

    COUNT(*) FILTER (
        WHERE s.shock_severity = 'Severe'
          AND s.shock_direction = 'Decrease'
    ) AS severe_decrease_months,

    ROUND(
        COUNT(*) FILTER (
            WHERE s.is_shock = TRUE
        ) * 100.0 / COUNT(*),
        2
    ) AS shock_month_share,

    -- OIL PRICE MOVEMENT

    oy.brent_return_pct AS annual_brent_return,

    MAX(s.brent_return_pct) FILTER (
        WHERE s.brent_return_pct > 0
    ) AS max_positive_brent_return,

    MIN(s.brent_return_pct) FILTER (
        WHERE s.brent_return_pct < 0
    ) AS max_negative_brent_return,

    -- ECONOMIC INDICATORS

    cy.gdp_current_usd,
    cy.gdp_growth,
    cy.gdp_per_capita,
    cy.inflation,
    cy.energy_imports,
    cy.energy_use,
    cy.imports,
    cy.exports

FROM analytics.fact_country_year cy

LEFT JOIN analytics.dim_shock s
    ON cy.year = s.year

LEFT JOIN analytics.fact_oil_yearly oy
    ON cy.year = oy.year

GROUP BY
    cy.country_key,
    cy.year,
    oy.brent_return_pct,
    cy.gdp_current_usd,
    cy.gdp_growth,
    cy.gdp_per_capita,
    cy.inflation,
    cy.energy_imports,
    cy.energy_use,
    cy.imports,
    cy.exports;


-- VALIDATION

SELECT *
FROM analytics.fact_country_shock
ORDER BY country_key, year;

SELECT
    year,
    total_shock_months,
    moderate_increase_months
        + moderate_decrease_months
        + severe_increase_months
        + severe_decrease_months AS calculated_shock_months,
    shock_month_share
FROM analytics.fact_country_shock
GROUP BY
    year,
    total_shock_months,
    moderate_increase_months,
    moderate_decrease_months,
    severe_increase_months,
    severe_decrease_months,
    shock_month_share
ORDER BY year;