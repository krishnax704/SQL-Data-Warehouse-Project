# 🏗️ SQL Data Warehouse Project

A end-to-end **Data Warehouse** built on SQL Server using a **Medallion Architecture** (Bronze → Silver → Gold), featuring full ETL pipelines, dimensional modeling, exploratory data analysis, and business reporting views.

---

## 📐 Project Architecture

```
Source Systems (CRM + ERP)
        │
        ▼
┌──────────────────┐
│   🥉 Bronze Layer │  ← Raw ingestion from CSV files (BULK INSERT)
└──────────────────┘
        │
        ▼
┌──────────────────┐
│   🥈 Silver Layer │  ← Cleaned, standardized, deduplicated data
└──────────────────┘
        │
        ▼
┌──────────────────┐
│   🥇 Gold Layer   │  ← Star schema: Dimensions + Fact + Reports
└──────────────────┘
```

---

## 📁 Project Structure

```
├── 🥉 Bronze Layer
│   └── bronze_layer.sql          # Stored procedure: BULK INSERT from CSV sources
│
├── 🥈 Silver Layer
│   ├── creatting_tables_bronze.sql  # DDL: Creates all silver tables
│   └── silver_layer.sql             # Stored procedure: Cleans & loads silver tables
│
├── 🥇 Gold Layer
│   ├── gold_dim_customer.sql     # View: Customer dimension
│   ├── gold_dim_products.sql     # View: Product dimension
│   └── gold_fact_sales.sql       # View: Sales fact table
│
├── 📊 Analytics
│   ├── EDA.sql                   # Exploratory Data Analysis queries
│   ├── customer_report.sql       # View: Customer KPI report
│   └── product_report.sql        # View: Product KPI report
```

---

## 🔄 Data Flow

### 🥉 Bronze Layer — Raw Ingestion

Loads raw data directly from CSV files using `BULK INSERT` inside a stored procedure (`bronze.load_bronze`). No transformations are applied.

**Source Tables:**

| Source System | Table | Description |
|---|---|---|
| CRM | `bronze.crm_cust_info` | Customer information |
| CRM | `bronze.crm_prd_info` | Product information |
| CRM | `bronze.crm_sales_details` | Sales transactions |
| ERP | `bronze.erp_cust_az12` | Customer demographics |
| ERP | `bronze.erp_loc_a101` | Customer locations |
| ERP | `bronze.erp_px_cat_g1v2` | Product categories |

---

### 🥈 Silver Layer — Cleansed & Standardized

Stored procedure `silver.load_silver` applies the following transformations:

- ✅ **Deduplication** — keeps latest record per customer using `ROW_NUMBER()`
- ✅ **Standardization** — gender (`M/F → Male/Female`), marital status (`S/M → Single/Married`), country codes (`DE → Germany`, `US → United States`)
- ✅ **Null handling** — fills missing costs with `0`, invalid prices derived from quantity × price
- ✅ **Date fixes** — invalid date integers (0 or wrong length) replaced with `NULL`
- ✅ **Product key parsing** — category ID extracted from product key prefix; surrogate end dates derived using `LEAD()`

---

### 🥇 Gold Layer — Dimensional Model (Star Schema)

#### 👤 `gold.dim_customers`
Customer dimension enriched from CRM + ERP sources:
- Surrogate key via `ROW_NUMBER()`
- Gender resolved with CRM as master (ERP as fallback)
- Includes: name, country, marital status, gender, birth date

#### 📦 `gold.dim_products`
Product dimension with category enrichment:
- Filters out historical records (`prd_end_dt IS NULL`)
- Joined with ERP category table for category, subcategory, and maintenance info

#### 🛒 `gold.fact_sales`
Central fact table joining sales transactions with product and customer dimension keys:
- Fields: order number, dates (order/ship/due), sales amount, quantity, price

---

## 📊 Analytics & Reporting

### 🔍 EDA (`EDA.sql`)

Comprehensive exploratory queries covering:

| Analysis Type | Examples |
|---|---|
| 📋 Database exploration | Schema inspection, column discovery |
| 🌍 Dimension exploration | Countries, categories, subcategories |
| 📅 Date range analysis | First/last order dates, customer age range |
| 📏 Magnitude analysis | Customers by country/gender, products by category |
| 📈 Trend analysis | Monthly/yearly sales trends |
| 📊 Cumulative analysis | Running totals, moving average price |
| ⚡ Performance analysis | YoY product sales vs. average |
| 🥧 Part-to-whole | Category contribution % to total revenue |
| 🎯 Segmentation | Customer segments (VIP/Regular/New), product cost ranges |
| 🏆 Ranking | Top/bottom products and customers by revenue |

---

### 👥 Customer Report (`gold.report_customer`)

A gold-layer view that consolidates customer KPIs:

- **Segments:** `VIP` (12+ months & >$5,000), `Regular` (12+ months & ≤$5,000), `New` (<12 months)
- **Age Groups:** 40–49, 50–59, 60–69, 70–79, 80+

**KPIs calculated:**

| Metric | Description |
|---|---|
| 🕒 Recency | Months since last order |
| 💰 Avg Order Value | Total sales ÷ total orders |
| 📅 Avg Monthly Spend | Total sales ÷ lifespan in months |
| 📦 Total Products | Distinct products purchased |
| 🔁 Total Orders | Distinct order count |

---

### 🛍️ Product Report (`gold.report_product`)

A gold-layer view that consolidates product KPIs:

- **Segments:** `High Performer` (>$50,000), `Mid-Range` (<$50,000)

**KPIs calculated:**

| Metric | Description |
|---|---|
| 🕒 Recency | Months since last sale |
| 💵 Avg Order Revenue (AOR) | Total sales ÷ total orders |
| 📅 Avg Monthly Revenue | Total sales ÷ lifespan in months |
| 👥 Total Customers | Unique customers per product |
| ⏳ Lifespan | Months between first and last sale |

---

## 🗄️ Tech Stack

| Component | Technology |
|---|---|
| Database | Microsoft SQL Server |
| ETL | T-SQL Stored Procedures |
| Ingestion | `BULK INSERT` from CSV |
| Modeling | Star Schema (Views) |
| Reporting | SQL Views (`gold.report_*`) |

---

## 🚀 How to Run

1. **Create Bronze tables** and run `bronze.load_bronze` to ingest raw CSV data
2. **Create Silver tables** using `creatting_tables_bronze.sql`
3. **Run** `silver.load_silver` to clean and load silver tables
4. **Create Gold views** — `dim_customers`, `dim_products`, `fact_sales`
5. **Create report views** — `report_customer`, `report_product`
6. **Run EDA queries** from `EDA.sql` for business insights

---

## 📌 Notes

- All stored procedures include **try/catch error handling** and **execution time logging** per table
- Gold views use `WHERE prd_end_dt IS NULL` to ensure only current product records are surfaced
- Customer gender resolution follows a **master-source pattern**: CRM takes precedence over ERP
