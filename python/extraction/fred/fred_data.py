import os
import time
from pathlib import Path

import requests
import pandas as pd
from dotenv import load_dotenv

# ============================================================
# CONFIGURATION
# ============================================================

load_dotenv()

FRED_API_KEY = os.getenv("FRED_API_KEY")

if not FRED_API_KEY:
    raise ValueError("FRED_API_KEY not found in .env file")

OUTPUT_DIR = Path("data/raw/fred")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

START_DATE = "2000-01-01"
END_DATE = "2025-12-31"

# ============================================================
# FRED SERIES
# ============================================================

SERIES = {
    "brent_crude_price": "DCOILBRENTEU",
    "wti_crude_price": "DCOILWTICO",

    "us_cpi": "CPIAUCSL",
    "fed_funds_rate": "FEDFUNDS",

    "us_gdp": "GDP",
    "us_unemployment": "UNRATE",
}

# ============================================================
# FRED API
# ============================================================

BASE_URL = "https://api.stlouisfed.org/fred/series/observations"

# ============================================================
# FETCH ONE SERIES
# ============================================================

def fetch_series(series_name, series_id):

    print("\n"+"="*60)
    print("SERIES:", series_name)
    print("ID:",series_id)
    print("\n"+"="*60)

    params = {
        "api_key": FRED_API_KEY,
        "file_type": "json",
        "series_id": series_id,
        "observation_start": START_DATE,
        "observation_end": END_DATE,
    }

    print("URL:", BASE_URL)
    print("PARAMS:",{
        "file_type": "json",
        "series_id": series_id,
        "observation_start": START_DATE,
        "observation_end": END_DATE,
    })

    # --------------------------------------------------------
    # REQUEST
    # --------------------------------------------------------

    for attempt in range(1,4):

        try:

            print(f"REQUEST ATTEMPT: {attempt}")

            response = requests.get(
                BASE_URL,
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
    # RAW OBSERVATIONS
    # --------------------------------------------------------

    observations = data["observations"]

    print("NUMBER OF OBSERVATIONS:", len(observations))

    print("\nFIRST 5 OBSERVATIONS:")

    for observation in observations[:5]:
        print(observation)

    # --------------------------------------------------------
    # DATAFRAME
    # --------------------------------------------------------

    df = pd.DataFrame(observations)

    print("\nSHAPE:", df.shape)

    print("\nCOLUMNS:")
    print(df.columns.tolist())

    # --------------------------------------------------------
    # SAVE RAW DATA
    # --------------------------------------------------------

    output_file = OUTPUT_DIR / f"{series_name}.csv"

    df.to_csv(output_file, index=False)

    print("\nSAVED TO:", output_file)

    return df

# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    print("=== FRED EXTRACTION STARTED ===")

    for series_name, series_id in SERIES.items():

        fetch_series(
            series_name,
            series_id
        )

    print("\n=== FRED EXTRACTION FINISHED ===")





