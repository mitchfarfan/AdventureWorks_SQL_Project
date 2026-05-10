/*-----------------------------------------PROJECT CONTEXT (READ FIRST)-------------------------------------------

This project builds a complete end‑to‑end BI pipeline using the AdventureWorks dataset. 

It includes:
-Loading raw CSV files for Sales (2015–2017), Customers, Products, Territories, Returns, and Calendar
-Cleaning and transforming inconsistent date formats, currency formats, and text fields
-Building a proper star schema (fact_sales, fact_returns, and all supporting dimensions)
-Applying primary keys and foreign keys after data quality issues are resolved
-Fixing real‑world referential integrity issues, including missing calendar dates that caused FK failures
-Running consolidated data validation checks to confirm completeness, grain, and integrity
-Answering business questions using CTEs, window functions, ranking, and moving averages
-A reset script is included so the entire pipeline can be re‑run cleanly from scratch.

This file is structured to respect the reader’s time: each section is self‑contained, 
clearly labelled, and aligned to the real‑world BI workflow.
--------------------------------------------------------------------------------------------------------------------


ADVENTUREWORKS — FINAL CURATED PROJECT SCRIPT

ETL → Validation → Business Analysis

============================================================
0. RESET SCRIPT (REPRODUCIBLE PIPELINE START)
==========================================================*/

DROP SCHEMA IF EXISTS aw CASCADE;
CREATE SCHEMA aw;
SET search_path TO aw;



/*============================================================

1. ETL

============================================================*/

/*============================================================
1A. SCHEMA CREATION
============================================================*/

SET search_path TO aw;

--Dimension structures (no PRIMARY KEYS yet)
CREATE TABLE aw.dim_product_categories (
    productcategorykey INTEGER,
    categoryname TEXT
);

CREATE TABLE aw.dim_product_subcategories (
    productsubcategorykey INTEGER,
    subcategoryname TEXT,
    productcategorykey INTEGER
);

CREATE TABLE aw.dim_products (
    productkey INTEGER,
    productsubcategorykey INTEGER,
    productsku TEXT,
    productname TEXT,
    modelname TEXT,
    productdescription TEXT,
    productcolor TEXT,
    productsize TEXT,
    productstyle TEXT,
    productcost NUMERIC,
    productprice NUMERIC
);

CREATE TABLE aw.dim_territories (
    territorykey INTEGER,
    region TEXT,
    country TEXT,
    continent TEXT
);


/*============================================================
1B. ETL — CALENDAR (DATE FIX)
============================================================*/

--Load raw text (CSV uses MM/DD/YYYY)
CREATE TABLE aw.dim_calendar (date_text TEXT);
COPY aw.dim_calendar FROM 'C:\\aw_data\\AdventureWorks_Calendar.csv' CSV HEADER;

--Convert → DATE
ALTER TABLE aw.dim_calendar ADD COLUMN date DATE;
UPDATE aw.dim_calendar SET date = TO_DATE(date_text, 'MM/DD/YYYY');
ALTER TABLE aw.dim_calendar DROP COLUMN date_text;


/*=============================================================
1C. ETL — CUSTOMERS (DATE + CURRENCY FIXES)
=============================================================*/

CREATE TABLE aw.dim_customers (
    customerkey INTEGER,
    prefix TEXT,
    firstname TEXT,
    lastname TEXT,
    birthdate_text TEXT,
    maritalstatus TEXT,
    gender TEXT,
    emailaddress TEXT,
    annualincome_text TEXT,
    totalchildren INTEGER,
    educationlevel TEXT,
    occupation TEXT,
    homeowner TEXT
);

COPY aw.dim_customers
FROM 'C:\\aw_data\\AdventureWorks_Customers.csv'
CSV HEADER ENCODING 'WIN1252';

--Fix date + currency
ALTER TABLE aw.dim_customers ADD COLUMN birthdate DATE;
UPDATE aw.dim_customers SET birthdate = TO_DATE(birthdate_text, 'MM/DD/YYYY');
ALTER TABLE aw.dim_customers DROP COLUMN birthdate_text;

ALTER TABLE aw.dim_customers ADD COLUMN annualincome NUMERIC;
UPDATE aw.dim_customers
SET annualincome = REPLACE(REPLACE(annualincome_text, '$', ''), ',', '')::NUMERIC;
ALTER TABLE aw.dim_customers DROP COLUMN annualincome_text;


/*============================================================
1D. ETL — RETURNS (DATE FIX)
============================================================*/

CREATE TABLE aw.fact_returns (
    returndate_text TEXT,
    territorykey INTEGER,
    productkey INTEGER,
    returnquantity INTEGER
);

COPY aw.fact_returns
FROM 'C:\\aw_data\\AdventureWorks_Returns.csv'
CSV HEADER;

ALTER TABLE aw.fact_returns ADD COLUMN returndate DATE;
UPDATE aw.fact_returns SET returndate = TO_DATE(returndate_text, 'MM/DD/YYYY');
ALTER TABLE aw.fact_returns DROP COLUMN returndate_text;


/*============================================================
1E. ETL — SALES 2015–2017 (DATE FIXES + STAGING)
============================================================*/

-- 2015 / 2016 / 2017 staging tables
-- (All follow the same pattern)

CREATE TABLE aw.stg_sales_2015 (
    OrderDate_text TEXT,
    StockDate_text TEXT,
    ordernumber TEXT,
    productkey INTEGER,
    customerkey INTEGER,
    territorykey INTEGER,
    orderlineitem INTEGER,
    orderquantity INTEGER
);

COPY aw.stg_sales_2015
FROM 'C:\\aw_data\\AdventureWorks_Sales_2015.csv'
CSV HEADER ENCODING 'WIN1252';

ALTER TABLE aw.stg_sales_2015
ADD COLUMN orderdate DATE,
ADD COLUMN stockdate DATE;

UPDATE aw.stg_sales_2015
SET orderdate = TO_DATE(OrderDate_text, 'MM/DD/YYYY'),
    stockdate = TO_DATE(StockDate_text, 'MM/DD/YYYY');

ALTER TABLE aw.stg_sales_2015 DROP COLUMN OrderDate_text, DROP COLUMN StockDate_text;

--(Repeat for 2016 and 2017 — unchanged)


/*============================================================
1F. LOAD STATIC DIMENSIONS
============================================================*/

COPY aw.dim_product_categories FROM 'C:\\aw_data\\AdventureWorks_Product_Categories.csv' CSV HEADER;
COPY aw.dim_product_subcategories FROM 'C:\\aw_data\\AdventureWorks_Product_Subcategories.csv' CSV HEADER;
COPY aw.dim_products FROM 'C:\\aw_data\\AdventureWorks_Products.csv' CSV HEADER;
COPY aw.dim_territories FROM 'C:\\aw_data\\AdventureWorks_Territories.csv' CSV HEADER;


/*============================================================
1G. BUILD FACT_SALES
============================================================*/

CREATE TABLE aw.fact_sales AS
SELECT * FROM aw.stg_sales_2015
UNION ALL
SELECT * FROM aw.stg_sales_2016
UNION ALL
SELECT * FROM aw.stg_sales_2017;

ALTER TABLE aw.fact_sales ADD COLUMN salesid SERIAL;

-- Validate row counts
SELECT
    (SELECT COUNT(*) FROM aw.stg_sales_2015) +
    (SELECT COUNT(*) FROM aw.stg_sales_2016) +
    (SELECT COUNT(*) FROM aw.stg_sales_2017) AS expected_total_rows,
    (SELECT COUNT(*) FROM aw.fact_sales) AS actual_total_rows;


/*============================================================
1H. ADD PRIMARY KEYS
============================================================*/

ALTER TABLE aw.dim_product_categories ADD PRIMARY KEY (productcategorykey);
ALTER TABLE aw.dim_product_subcategories ADD PRIMARY KEY (productsubcategorykey);
ALTER TABLE aw.dim_products ADD PRIMARY KEY (productkey);
ALTER TABLE aw.dim_territories ADD PRIMARY KEY (territorykey);
ALTER TABLE aw.dim_customers ADD PRIMARY KEY (customerkey);
ALTER TABLE aw.dim_calendar ADD PRIMARY KEY (date);
ALTER TABLE aw.fact_sales ADD PRIMARY KEY (salesid);


/*============================================================
1I. ADD FOREIGN KEYS 
============================================================*/

--Add FKs (first attempt)
ALTER TABLE aw.fact_sales
ADD CONSTRAINT fk_fact_sales_customer FOREIGN KEY (customerkey) REFERENCES aw.dim_customers(customerkey);

ALTER TABLE aw.fact_sales
ADD CONSTRAINT fk_fact_sales_product FOREIGN KEY (productkey) REFERENCES aw.dim_products(productkey);

ALTER TABLE aw.fact_sales
ADD CONSTRAINT fk_fact_sales_territory FOREIGN KEY (territorykey) REFERENCES aw.dim_territories(territorykey);

ALTER TABLE aw.fact_sales
ADD CONSTRAINT fk_fact_sales_orderdate FOREIGN KEY (orderdate) REFERENCES aw.dim_calendar(date);

--Stockdate FK failed — missing dates detected

--dentify missing dates
SELECT stockdate
FROM aw.fact_sales fs
LEFT JOIN aw.dim_calendar c ON fs.stockdate = c.date
WHERE c.date IS NULL
GROUP BY stockdate
ORDER BY stockdate;

--Fix: Insert missing calendar dates
INSERT INTO aw.dim_calendar(date)
SELECT d::date
FROM generate_series(
    '2001-09-11'::date,
    '2004-06-15'::date,
    interval '1 day'
) d
WHERE d::date NOT IN (SELECT date FROM aw.dim_calendar);

--Re‑apply FK (successful)
ALTER TABLE aw.fact_sales
ADD CONSTRAINT fk_fact_sales_stockdate FOREIGN KEY (stockdate) REFERENCES aw.dim_calendar(date);



/*============================================================

2. DATA VALIDATION — CONSOLIDATED

============================================================*/

/*============================================================
2A. TABLE COMPLETENESS (ROW COUNTS)
============================================================*/

--Why this matters:
--Confirms all tables loaded correctly

SELECT 
       schemaname,
       relname AS table_name,
       n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY schemaname, relname;


/*============================================================
2B. KEY INTEGRITY (PRIMARY & FOREIGN KEYS)
============================================================*/

--Why this matters:
--PKs and FKsmust be non‑null and unique to ensure each dimension member is identifiable.

-- Primary Key NULL check
SELECT COUNT(*) AS null_pk_customerkey
FROM aw.dim_customers
WHERE customerkey IS NULL;

-- Foreign Key NULL check
SELECT COUNT(*) AS null_fk_customer
FROM aw.fact_sales
WHERE customerkey IS NULL;


/*============================================================
2C. ORPHANED FACT ROWS (FK VIOLATIONS)
============================================================*/

--Why this matters:
-- Ensures fact rows correctly map to dimension members. 
--Must be zero before modelling

SELECT fs.customerkey
FROM aw.fact_sales fs
LEFT JOIN aw.dim_customers dc
       ON fs.customerkey = dc.customerkey
WHERE dc.customerkey IS NULL
GROUP BY fs.customerkey;


/*============================================================
2D. FACT TABLE GRAIN VALIDATION
============================================================*/

--Why this matters:
-- fact_sales grain = (ordernumber, orderlineitem). 
-- Ensures each row in the fact table represents a unique combination of dimension keys

SELECT ordernumber, orderlineitem, COUNT(*)
FROM aw.fact_sales
GROUP BY ordernumber, orderlineitem
HAVING COUNT(*) > 1;


/*============================================================
2E. DATE INTEGRITY (FACT DATES IN CALENDAR)
============================================================*/

--Why this matters:
-- Ensures all fact dates exist in dim_calendar.  
-- Critical for time-series modelling


SELECT orderdate
FROM aw.fact_sales fs
LEFT JOIN aw.dim_calendar c
       ON fs.orderdate = c.date
WHERE c.date IS NULL;


/*============================================================
2F. DUPLICATE KEY CHECKS
============================================================*/

--Why this matters:
-- PKs must be unique. 
--Duplicates break joins and BI logic

SELECT customerkey, COUNT(*)
FROM aw.dim_customers
GROUP BY customerkey
HAVING COUNT(*) > 1;


/*============================================================
2G. ONE-PAGE REFERENTIAL INTEGRITY SUMMARY
============================================================*/

-- Why this matters:
--Gives a single-view summary of FK health. 
--Critical for confirming data integrity before modelling

SELECT 
       'fact_sales ? dim_customers' AS relationship,
       COUNT(*) AS missing
FROM aw.fact_sales fs
LEFT JOIN aw.dim_customers dc
       ON fs.customerkey = dc.customerkey
WHERE dc.customerkey IS NULL;


/*============================================================

3. BUSINESS QUESTIONS + CTEs + WINDOW FUNCTIONS

============================================================*/

EXECUTIVE SUMMARY

--Revenue and profit are highly concentrated: top 20 SKUs drive 59% of revenue and 60% of profit.

--Both Revenue and Profit are concentrated ar similar levels, indicating margin dependency on a small SKU set.

--Several SKUs show declining demand over time, signalling potential delisting or pricing review.

--Lowest‑profit SKUs are not loss‑making but dilute margin and consume operational capacity.

--Low customer concentration risk (Top 20 Customers contribute 0.84% of revenue)

--Daily sales anomalies highlight promotional spikes and potential stockout days.

--Sales distribution is right‑skewed, increasing business risk if top SKUs fail.


/*============================================================
3A. WHICH PRODUCTS DRIVE THE MOST REVENUE?
=============================================================*/

-- Why this matters:
-- Revenue concentration shows where demand is strongest.
-- Helps identify high‑impact SKUs and business risk if top sellers fail.

-- Why we use a CTE here:
-- The CTE isolates the revenue calculation so the ranking logic stays clean.
-- This improves readability and avoids repeating the SUM() expression.


--Step 1: Calculate total revenue per product as CTE       
WITH revenue_calc AS (
       SELECT 
              fs.productkey,
              dp.productsku,
              dp.productname,
              SUM(fs.orderquantity * dp.productprice) AS total_revenue
       FROM aw.fact_sales fs
       LEFT JOIN aw.dim_products dp
              ON fs.productkey = dp.productkey
       -- Optional filter: uncomment to analyse a specific year
       -- WHERE DATE_PART('year', fs.orderdate) = 2016
       GROUP BY 
              fs.productkey,
              dp.productsku,
              dp.productname
)

--Step 2: Rank products by revenue and calculate percent of total
SELECT 
       productkey,
       productsku,
       productname,
       total_revenue,
       total_revenue / SUM(total_revenue) OVER () * 100 AS pct_of_total_revenue,
       SUM(total_revenue) OVER (ORDER BY total_revenue DESC)
              / SUM(total_revenue) OVER () * 100 AS running_pct_revenue,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM revenue_calc
ORDER BY 
       revenue_rank
LIMIT 20;

-- Insight:
-- A small number of SKUs generate a large share of total revenue.
-- Ranking highlights concentration and risk exposure.


/*============================================================
  3B. WHICH PRODUCTS GENERATE THE MOST PROFIT?
============================================================*/

-- Why this matters:
-- Revenue ≠ profit.
-- Profitability shows which products truly create value.
-- Identifying high‑profit SKUs helps prioritise pricing, promotion, and supply decisions.

-- Why we use a CTE here:
-- The first CTE aggregates quantity, sales, and cost.
-- The second CTE calculates profit cleanly.
-- This keeps the final SELECT readable and audit‑friendly.

--Step 1: Calculate total sales, cost, and profit per product as CTE
WITH product_sales AS (
       SELECT 
              fs.productkey,
              dp.productsku,
              dp.productname,
              SUM(fs.orderquantity) AS qty,
              SUM(fs.orderquantity * dp.productprice) AS total_sales,
              SUM(fs.orderquantity * dp.productcost) AS total_cost
       FROM aw.fact_sales fs
       LEFT JOIN aw.dim_products dp
              ON fs.productkey = dp.productkey
       -- Optional filter: uncomment to analyse a specific year
       -- WHERE DATE_PART('year', fs.orderdate) = 2016
       GROUP BY 
              fs.productkey,
              dp.productsku,
              dp.productname
),

--Step 2: Calculate profit and rank by profit as CTE
profit_calc AS (
       SELECT
              productkey,
              productsku,
              productname,
              qty,
              total_sales,
              total_cost,
              total_sales - total_cost AS total_profit
       FROM product_sales
)
--Step 3: Rank products by profit and calculate percent of total with running total
SELECT
       productkey,
       productsku,
       productname,
       qty,
       total_sales,
       total_cost,
       total_profit,
       total_profit / SUM(total_profit) OVER () * 100 AS pct_of_total_profit,
       SUM(total_profit) OVER (ORDER BY total_profit DESC)
              / SUM(total_profit) OVER () * 100 AS running_pct_profit,
       RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM profit_calc
ORDER BY 
       profit_rank
LIMIT 20;

-- Insight:
-- Profit is far more concentrated than revenue.
-- A small set of SKUs contributes a disproportionately large share of total profit.
-- The running total highlights dependency on top performers and supports strategic focus.


/*============================================================
  3C. WHICH PRODUCTS ARE DECLINING OVER TIME?
============================================================*/

-- Why this matters:
-- Trend analysis detects early signs of demand drop or supply issues.

-- Why we use a CTE here:
-- The CTE creates a clean monthly summary table.
-- This allows the moving average window function to operate on tidy, aggregated data.
-- It keeps the time‑series logic simple and readable.

--Step 1: Create monthly sales summary as CTE
WITH monthly_sales AS (
       SELECT 
              DATE_TRUNC('month', fs.orderdate) AS month,
              dp.productname,
              SUM(fs.orderquantity) AS qty
       FROM aw.fact_sales fs
       LEFT JOIN aw.dim_products dp
              ON fs.productkey = dp.productkey
       -- Optional filter: uncomment to analyse a specific year
       -- WHERE DATE_PART('year', fs.orderdate) = 2016
       GROUP BY 
              month,
              dp.productname
)

--Step 2: Calculate 3‑month moving average and rank by declining trend
SELECT 
       month,
       productname,
       qty,
       AVG(qty) OVER (
              PARTITION BY productname
              ORDER BY month
              ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS qty_moving_avg_3m
FROM monthly_sales
ORDER BY 
       productname,
       month;

-- Insight:

--Trend Detection
-- The 3‑month moving average smooths short‑term volatility and reveals directional trends.
-- Several products show gradual declines in monthly quantity, signalling potential demand softening.
-- Examples include All‑Purpose Bike Stand and Bike Wash – Dissolver, where moving averages taper off after early peaks.

--Operational Interpretation
-- Declining products may indicate market saturation, reduced promotional activity, or substitution by newer SKUs.
-- Stable or rising products (e.g., AWC Logo Cap) suggest sustained customer interest and effective pricing.
-- Moving averages help isolate true demand changes from random monthly fluctuations.

--Business Risk
-- Persistent downward trends can dilute overall category performance.
-- Early detection enables proactive action — price review, bundling, or discontinuation before losses accumulate.

--Recommended Actions
-- Flag SKUs with ≥3 consecutive months of declining moving averages for review.
-- Investigate marketing, pricing, or supply factors behind each decline.
-- Consider promotional refresh or product repositioning for softening SKUs.
-- Maintain monitoring cadence monthly to catch emerging declines early.

/*============================================================
  3D. WHICH PRODUCTS ARE GENERATING THE LOWEST PROFIT?
============================================================*/

-- Why this matters:
-- dilute overall profitability
-- consume warehouse, logistics, and marketing capacity
-- may require price review, cost renegotiation, or discontinuation

-- Why we use a CTE here:
-- The CTE isolates the total sales, total cost and total profit financial calculations.
-- This keeps the final WHERE clause simple and avoids repeating formulas.
-- It also makes the logic easier to audit.

--Step1: Calculate total sales, cost, and profit per product as CTE
WITH profit_calc AS (
       SELECT 
              fs.productkey,
              dp.productsku,
              dp.productname,
              SUM(fs.orderquantity * dp.productprice) AS total_sales,
              SUM(fs.orderquantity * dp.productcost) AS total_cost,
              SUM(fs.orderquantity * (dp.productprice - dp.productcost)) AS total_profit
       FROM aw.fact_sales fs
       LEFT JOIN aw.dim_products dp
              ON fs.productkey = dp.productkey
       -- Optional filter: uncomment to analyse a specific year
       -- WHERE DATE_PART('year', fs.orderdate) = 2016
       GROUP BY 
              fs.productkey,
              dp.productsku,
              dp.productname
)
--Step 2: Calculate profit and rank by profit
SELECT 
       productkey,
       productsku,
       productname,
       total_sales,
       total_cost,
       total_profit
FROM profit_calc
ORDER BY total_profit ASC
FETCH FIRST 20 ROWS ONLY;


-- Insight:
-- None of the product skus are unprofitable
-- small number of SKUs generate the smallest contribution to margin.
-- may be priced too low relative to cost
-- may have low sales volume, reducing their ability to absorb fixed costs
-- may be candidates for price review, promotional strategy changes, or SKU rationalisation


/*============================================================
  3E. WHICH CUSTOMERS CONTRIBUTE THE MOST VALUE?
  ============================================================*/

-- Why this matters:
-- Customer value concentration supports retention, upsell, and targeted marketing.
-- Understanding which customers drive revenue helps prioritise account management.

-- Why we use a CTE here:
-- The CTE creates a clean customer‑level revenue table.
-- This keeps the ranking and running-percentage logic simple and readable.

--Step 1: Calculate total revenue per customer as CTE
WITH customer_value AS (
       SELECT 
              fs.customerkey,
              dc.firstname,
              dc.lastname,
              SUM(fs.orderquantity * dp.productprice) AS customer_revenue
       FROM aw.fact_sales fs
       LEFT JOIN aw.dim_customers dc
              ON fs.customerkey = dc.customerkey
       LEFT JOIN aw.dim_products dp
              ON fs.productkey = dp.productkey
       GROUP BY 
              fs.customerkey,
              dc.firstname,
              dc.lastname
)
--step2: Rank customers by revenue and calculate percent of total with running total
SELECT 
       customerkey,
       firstname,
       lastname,
       customer_revenue,
       customer_revenue / SUM(customer_revenue) OVER () * 100 AS pct_of_total_revenue,
       SUM(customer_revenue) OVER (ORDER BY customer_revenue DESC)
              / SUM(customer_revenue) OVER () * 100 AS running_pct_revenue,
       RANK() OVER (ORDER BY customer_revenue DESC) AS revenue_rank
FROM customer_value
ORDER BY 
       revenue_rank
LIMIT 20;

--Insight:
-- Low customer concentration risk (Top 20 Customers contribute 0.84% of revenue)
-- Broad, diversified customer base
-- No large dominant customers dominating revenue
-- Marketing should focus on broad acquisition not high‑value retention
-- Churn risk is low because no single customer matters much


/*============================================================
3F. WHAT ANOMALIES OR UNUSUAL PATTERNS EXIST?
============================================================*/

-- Why this matters:
-- Anomalies reveal operational issues, promotions, seasonality, or data quality problems.

-- Why we use a CTE here:
-- The CTE creates a clean daily summary table.
-- This allows the window function to compare each day to the overall average.

--Step 1: Create daily sales summary as CTE
WITH daily_sales AS (
       SELECT 
              fs.orderdate,
              SUM(fs.orderquantity) AS qty
       FROM aw.fact_sales AS fs
       GROUP BY 
              fs.orderdate
)

--Step 2: Calculate deviation from average and rank by deviation
SELECT 
       orderdate,
       qty,
       AVG(qty) OVER () AS avg_daily_qty,
       qty - AVG(qty) OVER () AS deviation_from_avg
FROM daily_sales
ORDER BY 
       deviation_from_avg DESC;

--Insight:
-- Daily sales average ~92 units, but several days exceed 350–470 units, indicating extreme positive anomalies.
-- These spikes are 3–5× above normal volume and likely reflect promotions, bulk orders, or seasonal events.
-- Negative anomalies (very low‑volume days) likely correspond to stockouts, system downtime, or data gaps.

--Operational Interpretation
-- High‑volume spikes may require additional fulfilment capacity or inventory planning.
-- Low‑volume anomalies may signal operational issues that need investigation (e.g., supply chain delays).
-- Consistent patterns of spikes may indicate predictable seasonal cycles.


/*============================================================
3G. WHAT IS THE DISTRIBUTION OF SALES ACROSS PRODUCTS?
============================================================*/

-- Why this matters:
-- Distribution analysis shows whether sales are diversified or dominated by a few products.

-- Why we use a CTE here:
-- The CTE creates a simple product‑level quantity table.
-- This allows the percent‑of‑total window function to be applied cleanly.

--Step 1: Create product quantity summary as CTE
WITH product_qty AS (
       SELECT 
              dp.productname,
              SUM(fs.orderquantity) AS qty
       FROM aw.fact_sales fs
       LEFT JOIN aw.dim_products dp
              ON fs.productkey = dp.productkey
       GROUP BY 
              dp.productname
)
--Step 2: Calculate percent of total and running total
SELECT 
       productname,
       qty,
       qty * 1.0 / SUM(qty) OVER () * 100 AS pct_of_total,
       SUM(qty) OVER (ORDER BY qty DESC) / SUM(qty) OVER () * 100 AS running_pct_of_total

FROM product_qty
ORDER BY 
       qty DESC;

--Insight:
-- Sales volume is heavily right‑skewed, dominated by a small set of low‑price consumables.
--   Top 1 product-> ~9% of all units
--   Top 3 products -> ~23%
--   Top 5 products -> ~33%
--   Top 10 products -> ~45–50% (nearly half of total unit volume.)
--   High‑volume SKUs are mostly accessories (bottles, tubes, caps), not high‑value bikes.
  


/*============================================================
3H. Profit Margin Analysis (High vs Low Margin SKUs)
============================================================*/

-- Why this matters:
-- Shows which products have structurally low margins
-- Helps identify pricing issues

--Calculate total sales, cost, and profit per product
SELECT
    dp.productsku,
    dp.productname,
    SUM(fs.orderquantity * dp.productprice) AS total_sales,
    SUM(fs.orderquantity * dp.productcost) AS total_cost,
    (SUM(fs.orderquantity * dp.productprice) 
     - SUM(fs.orderquantity * dp.productcost)) AS total_profit,
    (SUM(fs.orderquantity * dp.productprice) 
     - SUM(fs.orderquantity * dp.productcost))
        / NULLIF(SUM(fs.orderquantity * dp.productprice), 0) * 100 AS profit_margin_pct
FROM aw.fact_sales fs
LEFT JOIN aw.dim_products dp
    ON fs.productkey = dp.productkey
GROUP BY
    dp.productsku,
    dp.productname
ORDER BY
    profit_margin_pct ASC
LIMIT 20;

--Insight:
-- Low‑margin SKUs (≈23%) -> likely apparel, price‑sensitive, may need cost review.
-- Mid‑margin SKUs (≈34–38%) -> accessories and bikes, healthier margins.
-- High‑margin SKUs (>40%) -> premium or niche products (you can check by reversing the sort).


/*============================================================
  ** BUSINESS ACTIONS **
  ============================================================*/

--Recommended Actions

-- Review pricing and margin strategy for lowest‑profit SKUs.
-- Prioritise supply chain reliability for top‑profit SKUs.
-- Marketing should focus on broad acquisition not high‑value retention as Top 20 Customers contribute only 0.84% of revenue. 
-- Investigate anomaly days for stockouts or promotions.
-- Consider SKU rationalisation for long‑tail, low‑volume products.




/*============================================================

  4. FUTURE ANALYSIS IDEAS

  ============================================================*/

--What I Would Do Next With More Time:
-- Add discount and returns logic for more accurate profit modelling
-- Build a Power BI dashboard with drill‑downs
-- Introduce customer segmentation (RFM or clustering)
--Add forecasting for declining SKUs */



/* End of Analysis
   All queries written for PostgreSQL.
   Each section can be executed independently.
*/