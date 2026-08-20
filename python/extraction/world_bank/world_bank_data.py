import requests
import pandas as pd
from pathlib import Path
import time


# ============================================================
# PROJECT ROOT
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[3]


# ============================================================
# CONFIGURATION
# ============================================================

COUNTRIES = (
    "IND;CHN;JPN;KOR;SGP;USA;DEU;"
    "GBR;FRA;CAN;AUS;BRA;SAU;ARE"
)

START_YEAR = 2000
END_YEAR = 2025

OUTPUT_DIR = PROJECT_ROOT / "data" / "raw" / "world_bank"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# WORLD BANK INDICATORS
# ============================================================

INDICATORS = {
    "gdp_current_usd": "NY.GDP.MKTP.CD",
    "gdp_growth": "NY.GDP.MKTP.KD.ZG",
    "gdp_per_capita": "NY.GDP.PCAP.CD",
    "inflation": "FP.CPI.TOTL.ZG",

    "energy_use": "EG.USE.PCAP.KG.OE",
    "energy_imports": "EG.IMP.CONS.ZS",

    "exports": "NE.EXP.GNFS.CD",
    "imports": "NE.IMP.GNFS.CD",
}


# ============================================================
# FUNCTION: FETCH ONE INDICATOR
# ============================================================

def fetch_indicator(indicator_name, indicator_code):

    print("\n" + "=" * 60)
    print("INDICATOR:", indicator_name)
    print("CODE:", indicator_code)
    print("=" * 60)

    url = (
        f"https://api.worldbank.org/v2/country/"
        f"{COUNTRIES}/indicator/{indicator_code}"
    )

    params = {
        "format": "json",
        "date": f"{START_YEAR}:{END_YEAR}",
        "per_page": 1000
    }

    print("URL:", url)
    print("PARAMS:", params)

    # --------------------------------------------------------
    # REQUEST
    # --------------------------------------------------------

    for attempt in range(1, 4):

        try:

            print(f"REQUEST ATTEMPT: {attempt}")

            response = requests.get(
                url,
                params=params,
                timeout=120
            )

            print("STATUS CODE:", response.status_code)

            response.raise_for_status()

            data = response.json()

            break

        except requests.RequestException as e:

            print("REQUEST ERROR:", e)

            if attempt == 3:
                raise

            print("Retrying...")
            time.sleep(3)

    # --------------------------------------------------------
    # CHECK RESPONSE
    # --------------------------------------------------------

    metadata = data[0]
    records = data[1]

    print("TOTAL RECORDS:", metadata["total"])
    print("PAGES:", metadata["pages"])
    print("LAST UPDATED:", metadata.get("lastupdated"))

    print("\nFIRST RAW RECORD:")
    print(records[0])

    # --------------------------------------------------------
    # CONVERT API RESPONSE TO FLAT TABLE
    # --------------------------------------------------------

    rows = []

    for record in records:

        indicator = record.get("indicator") or {}
        country = record.get("country") or {}

        rows.append({
            "indicator_code": indicator.get("id"),
            "indicator_name": indicator.get("value"),

            "country": country.get("value"),
            "countryiso3code": record.get("countryiso3code"),

            "year": record.get("date"),

            "value": record.get("value"),

            "unit": record.get("unit"),
            "obs_status": record.get("obs_status"),
            "decimal": record.get("decimal"),
        })

    df = pd.DataFrame(rows)

    # --------------------------------------------------------
    # BASIC EXTRACTION VALIDATION
    # --------------------------------------------------------

    print("\nDATAFRAME SHAPE:", df.shape)

    print("\nCOLUMNS:")
    print(df.columns.tolist())

    print("\nFIRST 3 ROWS:")
    print(df.head(3).to_string(index=False))

    # --------------------------------------------------------
    # SAVE
    # --------------------------------------------------------

    output_file = OUTPUT_DIR / f"{indicator_name}.csv"

    df.to_csv(
        output_file,
        index=False
    )

    print("\nSAVED TO:", output_file)

    return df


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    print("=== WORLD BANK EXTRACTION STARTED ===")

    for indicator_name, indicator_code in INDICATORS.items():

        fetch_indicator(
            indicator_name,
            indicator_code
        )

    print("\n=== WORLD BANK EXTRACTION FINISHED ===")