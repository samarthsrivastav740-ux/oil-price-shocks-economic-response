# 🛢️ Oil Price Shocks & Economic Response

A historical economic analysis project examining how major economies behaved during periods of unusually large oil-price movements using **FRED** and **World Bank** data.

The project combines **Python-based API extraction, data preparation, PostgreSQL data modeling & SQL analytics, and Power BI** to explore oil-market movements alongside country-level economic indicators.

> ⚠️ **Note:** This is an observational historical analysis. The project identifies economic patterns that occurred alongside unusual oil-price movements; it does **not** claim that oil prices caused changes in GDP growth or inflation.

---

## 📌 Project Overview

Oil prices can experience large and sudden movements, while the economic conditions and structures of countries exposed to those movements can differ substantially.

This project examines **14 major economies** and investigates what happened to their GDP growth, inflation, energy dependence, and trade indicators during historically unusual oil-price movements.

### 🔎 Key Questions

* 🛢️ When did major oil-price movements occur?
* 📈 How severe were these movements relative to historical oil-price behavior?
* 🌍 How did GDP growth and inflation behave during these periods?
* ⚖️ How did economic responses differ across countries?
* ⚡ Does energy-import dependence correspond to different observed economic patterns?
* 📊 How did different economies perform during similar oil-market conditions?

**Brent crude oil** is used as the primary analytical series, while **WTI crude oil** is used as a validation/reference series. The two series showed broadly similar behavior, allowing Brent to be used as the main measure throughout the analysis.

---

## 🌐 Data Sources

| Source        | Data                                                                                     | Frequency | Extraction Period | Analytical Period |
| ------------- | ---------------------------------------------------------------------------------------- | --------- | ----------------- | ----------------- |
| 🌍 World Bank | GDP, GDP Growth, GDP per Capita, Inflation, Energy Imports, Energy Use, Imports, Exports | Annual    | 2000–2025         | **2001–2022**     |
| 🛢️ FRED      | Brent Crude Oil Price                                                                    | Daily     | 2000–2025         | 2000–2025         |
| 🛢️ FRED      | WTI Crude Oil Price                                                                      | Daily     | 2000–2025         | 2000–2025         |

### 🌎 Countries Covered

The analysis covers 14 economies:

**United Arab Emirates · Australia · Brazil · Canada · China · Germany · France · United Kingdom · India · Japan · South Korea · Saudi Arabia · Singapore · United States**

### 📅 Why 2001–2022?

World Bank data was initially extracted for **2000–2025**. However, observations for **2000 and 2023–2025** were unavailable or incomplete across multiple countries.

Rather than using different periods for different countries, the analysis uses a common **2001–2022 analytical period** across all selected economies to maintain comparability.

---

## 🔄 Data Pipeline

```text
       FRED API                         World Bank API
           │                                 │
           └──────────────┬──────────────────┘
                          ▼
                    📁 Raw CSV Files
                          │
                          ▼
                 🧹 Jupyter Notebooks
            Basic Preparation + Data Validation
                          │
                          ▼
                 📁 Processed CSV Files
                          │
                          ▼
                🗄️ PostgreSQL Source
                          │
                          ▼
                🔧 PostgreSQL Staging
                 Type Standardization
                   + Null Handling
                          │
                          ▼
                📊 PostgreSQL Analytics
                    Dimensions + Facts
                          │
                          ▼
                🧠 Power BI Semantic Model
                          │
                          ▼
                   📈 4-Page Dashboard
```

---

## 🧹 Data Extraction & Preparation

### 🔌 API Extraction

Python scripts were developed to extract the datasets directly from the **FRED** and **World Bank APIs**.

The extraction layer preserves the source data separately from downstream processing.

### 📓 Jupyter Data Preparation

Dedicated notebooks were created for the **FRED** and **World Bank** datasets to prepare the extracted API data and perform initial data-quality checks before database ingestion.

The notebooks:

* 🗑️ Remove unnecessary API metadata and retain analytical fields
* 🔤 Standardize column names and structure
* 🔢 Convert dates, years, and numeric values to appropriate data types
* 📅 Inspect date and year coverage
* 🌍 Validate country coverage across the selected 14 economies
* 🔍 Profile missing values and inspect where they occur
* 🔁 Check for duplicate dates and country-year combinations
* ✅ Validate numeric values and inspect potentially invalid observations
* 💾 Save the prepared datasets to the `processed` data folder

The notebooks **do not perform analytical transformations or final null handling**. Missing observations are first inspected and preserved at this stage; source-specific handling is performed later in the PostgreSQL staging layer.

---

## 🗄️ PostgreSQL Architecture

PostgreSQL acts as the central database and analytical layer.

The database is organized into three schemas:

```text
📥 source
   ↓
🔧 staging
   ↓
📊 analytics
```

### 📥 Source Schema

Contains the processed source datasets loaded from the processed CSV files.

### 🔧 Staging Schema

The staging layer standardizes the source data before analysis.

Responsibilities include:

* Standardizing column data types
* Preparing fields for analytical use
* Handling missing values
* Preparing clean staging tables for downstream SQL transformations

### 📊 Analytics Schema

The analytics layer converts the staging data into reporting-ready **dimension and fact tables**.

---

## 🧩 Analytical Data Model

The analytics schema contains **3 dimension tables and 4 fact tables**.

### 📐 Dimension Tables

| Table         | Grain   | Purpose                                     |
| ------------- | ------- | ------------------------------------------- |
| `dim_country` | Country | Country reference and keys                  |
| `dim_date`    | Date    | Calendar attributes for time analysis       |
| `dim_shock`   | Month   | Oil-price movement and shock classification |

### 📊 Fact Tables

| Table                | Grain          | Purpose                                                          |
| -------------------- | -------------- | ---------------------------------------------------------------- |
| `fact_oil_monthly`   | Month          | Monthly Brent/WTI prices, returns, volatility and spread         |
| `fact_oil_yearly`    | Year           | Annualized oil-price metrics                                     |
| `fact_country_year`  | Country × Year | Country-level economic indicators                                |
| `fact_country_shock` | Country × Year | Economic indicators aligned with oil-price shock characteristics |

The analytical model provides separate grains for **oil-market analysis, annual economic analysis, and country-level shock analysis**, which are then connected through the Power BI semantic model.

---

## 📊 Oil-Price Shock Methodology

One of the key analytical decisions was to avoid defining an oil-price shock using an arbitrary fixed percentage.

Instead, monthly Brent returns were evaluated against their **empirical historical distribution**.

### 📈 Distribution-Based Classification

The Brent return distribution was profiled using:

* Minimum / Maximum
* Mean / Median
* Standard deviation
* P05 / P10
* P25 / P75
* P90 / P95
* P99

The percentile thresholds were then used to identify unusually large positive and negative movements.

### 🎯 Shock Classification

| Movement                 | Classification           |
| ------------------------ | ------------------------ |
| Brent return > **P95**   | 🔴 **Severe Increase**   |
| P90 < Brent return ≤ P95 | 🟠 **Moderate Increase** |
| P05 ≤ Brent return < P10 | 🟠 **Moderate Decrease** |
| Brent return < **P05**   | 🔴 **Severe Decrease**   |
| Otherwise                | ⚪ **Normal**             |

### 📌 Final Brent Thresholds

| Percentile |     Return |
| ---------- | ---------: |
| **P95**    | +13.45075% |
| **P90**    |  +10.4635% |
| **P10**    |  −10.2562% |
| **P05**    |  −14.4100% |

> 💡 The important point is that these thresholds were **derived from the historical Brent-return distribution using percentiles**, rather than manually choosing a fixed shock threshold.

The classification identifies unusually large price movements. It does **not** attempt to identify the geopolitical cause of those movements.

---

## 📈 Power BI Dashboard

The final Power BI dashboard contains **4 pages**, progressing from the global oil market to country-level economic observations.

### 1️⃣ Global Oil Market

**Question:** *When did major oil-price movements occur?*

Includes:

* 🛢️ Brent and WTI price trends
* 📊 Monthly Brent returns
* 🚨 Oil-price shock periods
* ↔️ Brent–WTI spread
* 📉 Brent–WTI volatility
* 🔎 Major observed oil-price movements

This page establishes the oil-market context before examining economic outcomes.

<img width="1278" height="722" alt="image" src="https://github.com/user-attachments/assets/d061442d-ffb4-4324-b025-f38ac40047ba" />


---

### 2️⃣ Economic Response

**Question:** *How did a selected economy move alongside oil-price movements?*

Includes:

* 💰 GDP
* 📈 GDP growth
* 👤 GDP per capita
* 📊 Inflation
* ⚡ Net energy imports
* 🔋 Per capita energy use
* 📦 Imports and exports
* 🛢️ Brent returns

The timeline allows oil-price movements and economic indicators to be viewed across the same years.

<img width="1277" height="720" alt="image" src="https://github.com/user-attachments/assets/a8822cb6-b4e8-4c75-a808-ddd391fd506e" />


---

### 3️⃣ Country Comparison

**Question:** *How did selected economies differ during oil-price shock periods?*

Includes:

* 📈 Average GDP growth during oil shocks
* 📊 Average inflation during oil shocks
* ⚡ Energy-import dependence

<img width="1282" height="726" alt="image" src="https://github.com/user-attachments/assets/61670591-4e87-402c-9c18-0d58aa6c3b88" />


---

### 4️⃣ Key Findings

The final page summarizes the major patterns observed throughout the analysis.

#### 🛢️ 01. Major shocks are concentrated in a few periods

The largest oil-market movements are concentrated around periods such as **2008–09 and 2020**, rather than remaining consistently elevated throughout the entire period.

#### 📉 02. Greater shock severity is associated with weaker GDP growth

As oil-price increases become more severe, GDP growth generally declines across several of the observed economies.

#### 🌍 03. Inflation responses differ sharply across countries

Countries such as Brazil and India experienced relatively higher inflation during oil shocks, while Japan remained comparatively low.

#### 🇨🇳🇮🇳 04. China and India maintained stronger growth

China and India recorded substantially stronger GDP growth during the observed oil-shock periods than several economies such as Japan, Germany and France.

#### ⚡ 05. Energy-import dependence does not predict economic performance

Higher energy-import dependence does not consistently correspond to weaker GDP growth or higher inflation across the selected economies.

#### 📅 06. 2020 produced the broadest economic downturn

Across the selected countries, 2020 stands out as a period of sharp GDP-growth decline followed by a broad recovery.

> ⚠️ These findings describe **observed historical patterns**. They should not be interpreted as evidence that oil-price movements caused the observed economic outcomes.

<img width="1283" height="725" alt="image" src="https://github.com/user-attachments/assets/cfbcb1bf-99b2-4311-b9bd-69d7be109eab" />


---

## 🧠 Key Analytical Outputs

The project produces analytical outputs across three levels.

### 🛢️ Oil Market

* Monthly and annual Brent/WTI prices
* Monthly oil-price returns
* Oil-price volatility
* Brent–WTI spread
* Historical shock classification
* Major positive and negative movements

### 🌍 Economic Response

* GDP
* GDP growth
* GDP per capita
* Inflation
* Energy imports and use
* Imports and exports

### ⚖️ Cross-Country Analysis

* Average GDP growth during shock periods
* Average inflation during shock periods
* Energy-import exposure
* Country comparisons

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| 🔌 Data Extraction & Preparation | Python, Pandas, Jupyter |
| 🗄️ Database | PostgreSQL |
| 🔧 Data Transformation | SQL |
| 📊 Semantic Modeling & BI | Power BI |
| 🌿 Version Control | Git & GitHub |

---

## ⚠️ Limitations

* 📌 The analysis is **observational and descriptive** and does not establish causal effects of oil prices on GDP growth or inflation.
* 📅 FRED oil-price data is daily while World Bank economic indicators are annual, requiring aggregation and alignment.
* 🌍 The analysis covers 14 selected economies rather than the entire global economy.
* 🛢️ Oil-price shock classification identifies unusually large historical movements but does not establish their geopolitical causes.
* ⚖️ Countries have different economic structures, scales, and energy-market exposure, so cross-country comparisons should be interpreted in context.
* 📆 The economic analysis is restricted to **2001–2022** for consistent country-level World Bank coverage.

---

