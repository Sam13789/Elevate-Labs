-- =====================================================================
-- TASK 6: Sales Trend Analysis Using Aggregations
-- Objective: Analyze monthly revenue and order volume
-- Dataset: online_sales database with orders table
-- Tools: MySQL (with PostgreSQL/SQLite variants included)
-- =====================================================================

-- Setup: Create sample schema and data structure
CREATE DATABASE IF NOT EXISTS online_sales;
USE online_sales;

-- Main table structure (adjust based on your actual data)
-- Expected columns: order_date, amount, product_id, order_id
-- Note: Using online_retail_raw as our orders table

-- =====================================================================
-- CORE ANALYSIS QUERIES
-- =====================================================================

-- 1. MONTHLY REVENUE AND ORDER VOLUME ANALYSIS
-- Groups data by year/month and calculates key metrics
SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    
    -- Revenue calculation using SUM()
    ROUND(SUM(quantity * unit_price), 2) AS monthly_revenue,
    
    -- Order volume using COUNT(DISTINCT order_id)
    COUNT(DISTINCT invoice) AS order_volume,
    
    -- Additional metrics
    ROUND(AVG(quantity * unit_price), 2) AS avg_order_value,
    COUNT(*) AS total_line_items
    
FROM online_retail_raw
WHERE invoice_date IS NOT NULL
  AND quantity > 0 
  AND unit_price > 0
GROUP BY EXTRACT(YEAR FROM invoice_date), EXTRACT(MONTH FROM invoice_date)
ORDER BY year, month;

-- 2. TOP 3 MONTHS BY SALES (Revenue-based ranking)
SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    ROUND(SUM(quantity * unit_price), 2) AS monthly_revenue,
    COUNT(DISTINCT invoice) AS order_volume
FROM online_retail_raw
WHERE invoice_date IS NOT NULL
  AND quantity > 0 
  AND unit_price > 0
GROUP BY EXTRACT(YEAR FROM invoice_date), EXTRACT(MONTH FROM invoice_date)
ORDER BY monthly_revenue DESC
LIMIT 3;

-- 3. FILTERED TIME PERIOD ANALYSIS (Specific year example)
SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    ROUND(SUM(quantity * unit_price), 2) AS monthly_revenue,
    COUNT(DISTINCT invoice) AS order_volume
FROM online_retail_raw
WHERE invoice_date >= '2010-01-01' 
  AND invoice_date < '2011-01-01'
  AND quantity > 0 
  AND unit_price > 0
GROUP BY EXTRACT(YEAR FROM invoice_date), EXTRACT(MONTH FROM invoice_date)
ORDER BY year, month;

-- 4. QUARTER-LEVEL AGGREGATION
SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(QUARTER FROM invoice_date) AS quarter,
    ROUND(SUM(quantity * unit_price), 2) AS quarterly_revenue,
    COUNT(DISTINCT invoice) AS order_volume
FROM online_retail_raw
WHERE invoice_date IS NOT NULL
  AND quantity > 0 
  AND unit_price > 0
GROUP BY EXTRACT(YEAR FROM invoice_date), EXTRACT(QUARTER FROM invoice_date)
ORDER BY year, quarter;

-- =====================================================================
-- DATABASE-SPECIFIC VARIANTS
-- =====================================================================

-- POSTGRESQL VERSION
/*
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(COALESCE(amount, 0)) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS order_volume
FROM online_sales.orders
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY year, month;
*/

-- SQLITE VERSION
/*
SELECT 
    CAST(strftime('%Y', order_date) AS INTEGER) AS year,
    CAST(strftime('%m', order_date) AS INTEGER) AS month,
    SUM(COALESCE(amount, 0)) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS order_volume
FROM orders
WHERE order_date IS NOT NULL
GROUP BY CAST(strftime('%Y', order_date) AS INTEGER),
         CAST(strftime('%m', order_date) AS INTEGER)
ORDER BY year, month;
*/

-- =====================================================================
-- ADVANCED ANALYSIS QUERIES
-- =====================================================================

-- 5. MONTH-OVER-MONTH GROWTH ANALYSIS
WITH monthly_data AS (
    SELECT 
        EXTRACT(YEAR FROM invoice_date) AS year,
        EXTRACT(MONTH FROM invoice_date) AS month,
        SUM(quantity * unit_price) AS monthly_revenue
    FROM online_retail_raw
    WHERE invoice_date IS NOT NULL
      AND quantity > 0 
      AND unit_price > 0
    GROUP BY EXTRACT(YEAR FROM invoice_date), EXTRACT(MONTH FROM invoice_date)
),
monthly_with_lag AS (
    SELECT 
        year,
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY year, month) AS prev_month_revenue
    FROM monthly_data
)
SELECT 
    year,
    month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(prev_month_revenue, 2) AS prev_month_revenue,
    ROUND(
        CASE 
            WHEN prev_month_revenue > 0 
            THEN ((monthly_revenue - prev_month_revenue) / prev_month_revenue) * 100
            ELSE NULL
        END, 2
    ) AS growth_rate_percent
FROM monthly_with_lag
ORDER BY year, month;

-- 6. NULL HANDLING DEMONSTRATION
SELECT 
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    
    -- Different COUNT variations
    COUNT(*) AS total_rows,
    COUNT(invoice) AS non_null_invoices,
    COUNT(DISTINCT invoice) AS distinct_invoices,
    
    -- NULL-safe aggregations
    SUM(COALESCE(quantity * unit_price, 0)) AS revenue_null_safe,
    AVG(COALESCE(quantity * unit_price, 0)) AS avg_null_safe
    
FROM online_retail_raw
WHERE EXTRACT(YEAR FROM invoice_date) = 2010
GROUP BY EXTRACT(YEAR FROM invoice_date), EXTRACT(MONTH FROM invoice_date)
ORDER BY year, month;

-- =====================================================================
-- VERIFICATION QUERIES
-- =====================================================================

-- Data quality check
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT invoice) as unique_orders,
    MIN(invoice_date) as earliest_date,
    MAX(invoice_date) as latest_date,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) as null_dates
FROM online_retail_raw;
