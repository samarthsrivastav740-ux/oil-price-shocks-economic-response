import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

from python.utils.file_paths import PROCESSED_TABLES

# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

load_dotenv()

DATABASE = os.getenv("DB_NAME")
USER = os.getenv("DB_USER")
PASSWORD = os.getenv("DB_PASSWORD")
HOST = os.getenv("DB_HOST")
PORT = os.getenv("DB_PORT")

# ============================================================
# POSTGRESQL CONNECTION
# ============================================================

engine = create_engine(
    f"postgresql+psycopg2://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
)

# ============================================================
# LOAD TABLE
# ============================================================

def load_table(table_name, csv_path):
    """
    Reads a processed CSV file and loads it
    into the PostgreSQL source schema.
    """

    print(f"\nLoading {table_name}....")

    df = pd.read_csv(csv_path)

    df.to_sql(
        name=table_name,
        con=engine,
        schema="source",
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=10000
    )

    print(
        f"✓ {table_name} loaded successfully "
        f"({len(df):,} rows)"
    )

# ============================================================
# MAIN
# ============================================================

def main():

    print("=" * 60)
    print("Loading processed CSV files into PostgreSQL")
    print("=" * 60)

    failed_tables = []

    for table_name, csv_path in PROCESSED_TABLES.items():

        try:

            load_table(
                table_name,
                csv_path
            )

        except Exception as e:

            print(f"✗ Failed to load {table_name}")
            print(e)

            failed_tables.append(table_name)

    # --------------------------------------------------------
    # FINAL STATUS
    # --------------------------------------------------------

    print("\n" + "=" * 60)

    if failed_tables:

        print("INGESTION COMPLETED WITH ERRORS")

        print("\nFailed tables:")

        for table in failed_tables:
            print(f"  - {table}")

    else:

        print("ALL TABLES LOADED SUCCESSFULLY")

    print("=" * 60)

# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":
    main()

