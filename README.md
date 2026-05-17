# AdventureWorks SQL Analysis — Business Insights & Analytical SQL Portfolio

A structured SQL analysis designed to demonstrate commercial thinking, analytical capability, and clean, auditable SQL patterns.

---

## 1. Overview
This project demonstrates end‑to‑end analytical SQL capability using the AdventureWorks dataset.  
The analysis focuses on revenue, profitability, customer value, product trends, and operational anomalies — the core areas a BI Analyst or Analytics Professional is expected to handle.

The SQL is written for **PostgreSQL**, using **CTEs**, **window functions**, and **financial logic**.


## How This Project Demonstrates BI Thinking
This project mirrors the analytical workflow used in BI teams:

- structured ingestion and cleaning of raw transactional data  
- referential integrity validation to ensure trustworthy modelling  
- business‑logic modelling using CTEs and financial fields  
- insight generation aligned to commercial priorities and decision‑making  

## Why SQL First
This phase focuses on analytical traceability — producing clean, auditable outputs before visualisation.  
Power BI will be layered on top once the analytical foundation is validated and stable.

## Key SQL Patterns Used
- window functions for ranking and trend detection  
- CTEs for readable, modular business logic  
- integrity checks for grain, keys, and completeness  
- financial modelling using cost, price, and derived profit metrics  

## Business Questions Answered
A structured set of commercial questions covering:

- revenue concentration  
- margin performance  
- customer value  
- product trends  
- operational anomalies  

---

## 2. Dataset Summary
- **Fact table:** `fact_sales` — daily sales transactions  
- **Dimensions:** `dim_products`, `dim_customers`  
- **Time granularity:** daily  
- **Financial fields:** product price, product cost  
- **Exclusions:** discounts, returns, freight (future enhancement)

---

## 3. Repository Structure
- `/sql/` — All SQL scripts used in the analysis  
- `/screenshots/` — Output screenshots and visual evidence  
- `README.md` — Project overview and business insights  

---

## 4. Executive Summary
The analysis highlights several key commercial insights:

- **Revenue and profit are highly concentrated** — top 20 SKUs contribute ~59% of revenue and ~60% of profit.  
- **Margin dependency is high**, with a small SKU set driving most value.  
- **Several SKUs show declining demand**, indicating potential delisting or pricing review.  
- **Lowest‑profit SKUs are not loss‑making**, but dilute margin and consume operational capacity.  
- **Customer concentration risk is extremely low** — top 20 customers contribute only 0.84% of revenue.  
- **Daily sales anomalies** reveal promotional spikes and potential stockout days.  
- **Sales distribution is right‑skewed**, dominated by low‑price consumables.

These findings support pricing optimisation, SKU rationalisation, and operational planning.

---

## 5. Analytical Areas Covered

### 5.1 Revenue Concentration (3A)
- Identifies top‑performing SKUs
- Uses CTEs + window functions for ranking and running %
- Highlights commercial dependency on a small product set 

### 5.2 Profitability Analysis (3B)
- Clean profit modelling using aggregated CTEs  
- Ranks SKUs by total profit contribution  
- Surfaces margin‑dilutive products  

### 5.3 Declining Product Trends (3C)
- Detects declining SKUs using 3‑month moving averages
- Uses window functions for smoothing
- Supports early intervention on softening demand

### 5.4 Lowest‑Profit Products (3D)
- Identifies products that consume capacity but add limited value
- Supports pricing review or SKU rationalisation

### 5.5 Top Value Customers (3E)
- Ranks customers by revenue contribution
- Confirms diversified customer base and low churn risk

### 5.6 Daily Sales Anomalies (3F)
- Compares daily sales to overall average
- Highlights promotional spikes and potential stockouts

### 5.7 Sales Distribution by Product (3G)
- Shows right‑skewed distribution
- Quantifies contribution of top 1, 3, 5, 10 SKUs

### 5.8 Profit Margin Analysis (3H)
- Calculates margin % by SKU
- Highlights categories with structurally low margins
- Supports pricing and cost‑management decisions 

---

## 6. Recommended Business Actions
- **Review pricing and margin strategy** for lowest‑profit SKUs  
- **Prioritise supply chain reliability** for top‑profit SKUs  
- **Focus marketing on broad acquisition**, not retention, due to low customer concentration  
- **Investigate anomaly days** for stockouts or promotions  
- **Consider SKU rationalisation** for long‑tail, low‑volume products  

---

## 7. Future Enhancements
With additional time, the following improvements would be implemented:

- Incorporate **discounts, returns, and freight** for more accurate profit modelling  
- Build a **Power BI dashboard** with drill‑downs and trend visuals  
- Introduce **customer segmentation** (RFM or clustering)  
- Add **forecasting** for declining SKUs  
- Extend analysis to **inventory, lead times, and stockouts**  

---

## 8. How to Run the SQL
- Queries are written for **PostgreSQL**  
- Each section is self‑contained and can be executed independently  
- CTEs and window functions are used for clarity and auditability  

---

## Closing Note
This project reflects my approach to analytical work: structured, commercially grounded, and focused on delivering decision‑ready insights.
