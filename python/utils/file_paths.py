from pathlib import Path

# ============================================================
# Project Root
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

# ============================================================
# Data Folders
# ============================================================

DATA_FOLDER = PROJECT_ROOT / "data"

RAW_FOLDER = DATA_FOLDER / "raw"
PROCESSED_FOLDER = DATA_FOLDER / "processed"


# ============================================================
# Raw Data Source Folders
# ============================================================

FRED_RAW_FOLDER = RAW_FOLDER / "fred"
WORLD_BANK_RAW_FOLDER = RAW_FOLDER / "world_bank"


# ============================================================
# Processed Data Source Folders
# ============================================================

FRED_PROCESSED_FOLDER = PROCESSED_FOLDER / "fred"
WORLD_BANK_PROCESSED_FOLDER = PROCESSED_FOLDER / "world_bank"


# ============================================================
# FRED Raw Files
# ============================================================

BRENT_CRUDE_PRICE = (
    FRED_RAW_FOLDER / "brent_crude_price.csv"
)

WTI_CRUDE_PRICE = (
    FRED_RAW_FOLDER / "wti_crude_price.csv"
)


# ============================================================
# World Bank Raw Files
# ============================================================

ENERGY_IMPORTS = (
    WORLD_BANK_RAW_FOLDER / "energy_imports.csv"
)

ENERGY_USE = (
    WORLD_BANK_RAW_FOLDER / "energy_use.csv"
)

GDP_CURRENT_USD = (
    WORLD_BANK_RAW_FOLDER / "gdp_current_usd.csv"
)

GDP_GROWTH = (
    WORLD_BANK_RAW_FOLDER / "gdp_growth.csv"
)

GDP_PER_CAPITA = (
    WORLD_BANK_RAW_FOLDER / "gdp_per_capita.csv"
)

IMPORTS = (
    WORLD_BANK_RAW_FOLDER / "imports.csv"
)

EXPORTS = (
    WORLD_BANK_RAW_FOLDER / "exports.csv"
)

INFLATION = (
    WORLD_BANK_RAW_FOLDER / "inflation.csv"
)

# ============================================================
# PROCESSED FRED FILES
# ============================================================

BRENT_CRUDE_PRICE_PROCESSED = (
    FRED_PROCESSED_FOLDER / "brent_crude_price.csv"
)

WTI_CRUDE_PRICE_PROCESSED = (
    FRED_PROCESSED_FOLDER / "wti_crude_price.csv"
)

# ============================================================
# PROCESSED WORLD BANK FILES
# ============================================================


ENERGY_IMPORTS_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "energy_imports.csv"
)

ENERGY_USE_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "energy_use.csv"
)

GDP_CURRENT_USD_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "gdp_current_usd.csv"
)

GDP_GROWTH_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "gdp_growth.csv"
)

GDP_PER_CAPITA_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "gdp_per_capita.csv"
)

IMPORTS_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "imports.csv"
)

EXPORTS_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "exports.csv"
)

INFLATION_PROCESSED = (
    WORLD_BANK_PROCESSED_FOLDER / "inflation.csv"
)

# ============================================================
# PROCESSED TABLES FOR POSTGRESQL INGESTION
# ============================================================

PROCESSED_TABLES = {

    # -------------------------
    # FRED
    # -------------------------

    "fred_brent_crude_price": BRENT_CRUDE_PRICE_PROCESSED,

    "fred_wti_crude_price": WTI_CRUDE_PRICE_PROCESSED,


    # -------------------------
    # WORLD BANK
    # -------------------------

    "wb_energy_imports": ENERGY_IMPORTS_PROCESSED,

    "wb_energy_use": ENERGY_USE_PROCESSED,

    "wb_gdp": GDP_CURRENT_USD_PROCESSED,

    "wb_gdp_growth": GDP_GROWTH_PROCESSED,

    "wb_gdp_per_capita": GDP_PER_CAPITA_PROCESSED,

    "wb_imports": IMPORTS_PROCESSED,

    "wb_exports": EXPORTS_PROCESSED,

    "wb_inflation": INFLATION_PROCESSED,
}