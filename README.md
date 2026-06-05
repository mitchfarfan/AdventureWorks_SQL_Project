# AdventureWorks SQL Analysis — Business Insights & Analytical SQL Portfolio

A complete SQL‑driven analytical project demonstrating mid‑level BI capability, commercial reasoning, and clean, auditable SQL patterns across core business performance areas.

This project shows how raw transactional data can be transformed into decision‑ready insights using structured SQL, financial modelling, and BI‑aligned analytical workflows.

---

## Quick Links

**Excel Workbook (Interactive Analysis)**  
[AdventureWorks_Analysis.xlsx](https://github.com/mitchfarfan/AdventureWorks_SQL_Project/raw/main/AdventureWorks_Analysis.xlsx)

**Full SQL Project File**  
[AdventureWorks_SQL_Project.sql](https://github.com/mitchfarfan/AdventureWorks_SQL_Project/blob/main/AdventureWorks_SQL_Project.sql)

**Execution Screenshots (VS Code)**  
https://github.com/mitchfarfan/AdventureWorks_SQL_Project/tree/main/Screenshots

---

## What This Project Demonstrates

-**Analytical SQL proficiency** — CTEs, window functions, financial logic, anomaly detection
-**Commercial thinking** — revenue concentration, margin performance, customer value, product lifecycle trends
-**Data integrity discipline** — validating grain, keys, and completeness before modelling
-**BI workflow alignment** — modular SQL logic, reproducible outputs, packaged Excel deliverables
-**Insight communication** — clear summaries, structured outputs, and business‑ready recommendations

---

## 1. Project Overview

This project delivers an end‑to‑end analytical SQL workflow using the **AdventureWorks** dataset.

The analysis focuses on the commercial levers most relevant to BI and analytics roles:

-**revenue concentration**
-**profit and margin performance**
-**customer value distribution**
-**product lifecycle and declining trends**
-**operational anomalies**
-**sales distribution patterns**

SQL is written for **PostgreSQL**, using **CTEs**, **window functions**, and **financial modelling** to ensure clarity, auditability, and commercial relevance.

A packaged Excel workbook consolidates all outputs into a clean, analyst‑ready deliverable.

---

## 2. Why This Project Matters for BI Roles

This project mirrors real BI team workflows by demonstrating:

-**structured ingestion** of transactional data
-**referential integrity checks** to ensure trustworthy modelling
-**modular SQL logic** using CTEs for readability and auditability
-**financial modelling** using price, cost, and derived profit metrics
-**trend and anomaly detection** using window functions
-**insight generation** aligned to commercial decision‑making
-**packaged outputs** suitable for stakeholders

This is the type of analytical foundation expected in BI, analytics, and data‑driven commercial roles.

---

## 3. Dataset Summary

- **Fact table:** `fact_sales` — daily sales transactions
- **Dimensions:** `dim_products`, `dim_customers`
- **Time granularity:** daily
- **Financial fields:** product price, product cost
- **Exclusions:** discounts, returns, freight (future enhancement)

---

## 4. Repository Structure

- `/sql/` — All SQL scripts used in the analysis
- `/screenshots/` — Execution screenshots (VS Code)
- `/excel/` — Packaged Excel workbook
- `README.md` — Project overview, insights, and documentation

---

## 5. Executive Summary — Key Insights

Across all analytical modules (3A–3H), several consistent commercial themes emerge:

### 1. Revenue & Profit Concentration
A small set of SKUs drives a disproportionately large share of revenue and profit.
This creates **product dependency risk** and highlights the importance of supply chain reliability for top performers.

### 2. Margin Variability
High‑revenue SKUs are not always the most profitable.
Several mid‑volume products deliver stronger margins, indicating **misaligned promotional focus**.

### 3. Declining Product Trends
Multiple SKUs show sustained downward trends, signalling potential **lifecycle decline, competitive pressure, or reduced promotional activity**.

### 4. Customer Value Distribution
Customer concentration risk is extremely low — revenue is widely distributed across the customer base.
This supports a **broad acquisition strategy** rather than heavy retention focus.

### 5. Operational Anomalies
Daily sales anomalies reveal **promotional spikes, stockouts,** or **data quality gaps**.
These require monitoring to improve forecasting and operational planning.

### 6. Sales Distribution
Sales are heavily **right‑skewed**, dominated by low‑price consumables.
This impacts inventory planning and margin strategy.

**Overall:**  
The business is **commercially strong but operationally imbalanced**, with clear opportunities to improve margin, product mix, and forecasting accuracy.

---

## 6. Analytical Modules (3A–3H)

Each module includes SQL logic, results, and business interpretation.

### 3A — Revenue Concentration
-**Identifies top‑performing SKUs** using CTEs + window functions
-**Highlights dependency** on a narrow product set

### 3B — Profitability Analysis
-**Models total profit** using aggregated CTEs
-**Surfaces margin‑dilutive products** and high‑value SKUs

### 3C — Declining Product Trends
-**Uses 3‑month moving averages** to detect downward trends
-**Supports lifecycle management** and pricing review

### 3D — Lowest‑Profit Products
-**Identifies SKUs** that generate revenue but dilute margin
-**Useful for SKU rationalisation** and cost review

### 3E — Top Value Customers
-**Ranks customers** by revenue contribution
-**Confirms low concentration risk**

### 3F — Daily Sales Anomalies
-**Detects spikes and dips** relative to average daily sales
-**Useful for operational monitoring** and forecasting

### 3G — Sales Distribution by Product
-**Quantifies contribution** of top 1, 3, 5, 10 SKUs
-**Reveals right‑skewed distribution**

### 3H — Profit Margin Analysis
-**Calculates margin %** by SKU and category
-**Supports pricing and supplier negotiation decisions**

---

## 7. Recommended Business Actions

-**Shift focus from revenue to profit** — prioritise high‑margin SKUs in marketing and promotions
-**Rationalise long‑tail SKUs** — review low‑volume, low‑profit products for delisting or repositioning
-**Strengthen pricing governance** — revisit pricing for margin‑dilutive SKUs
-**Investigate declining SKUs** — assess competitive, pricing, or seasonality factors
-**Improve operational monitoring** — implement anomaly detection dashboards
-**Leverage customer diversification** — focus on broad acquisition rather than retention

---

## 8. Future Enhancements

Planned improvements include:

-**Incorporate discounts, returns, and freight** for more accurate profit modelling
-**Build a Power BI dashboard** with drill‑downs and trend visuals
-**Introduce customer segmentation** (RFM or clustering)
-**Add forecasting** for declining SKUs
-**Extend analysis** to inventory, lead times, and stockouts

---

## 9. How to Run the SQL

- Queries are written for **PostgreSQL**
- Each section is self‑contained and can be executed independently
- CTEs and window functions are used for clarity and auditability

---

## Closing Note

This project reflects my approach to analytical work:
**structured, commercially grounded, and focused on delivering decision‑ready insights.**
