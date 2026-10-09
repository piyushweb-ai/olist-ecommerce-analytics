-- 01_data_quality.sql
-- Olist e-commerce analytics | Engine: DuckDB (standard SQL, minor changes needed for PostgreSQL)
-- Goal: understand the tables and check data quality before any analysis.
-- Analysis window used in later files: Jan 2017 - Aug 2018 (other months have almost no data).


-- Q1. Column names and data types of the orders table
DESCRIBE orders;


-- Q2. Orders by status, with share of total
-- Finding: 97.02% of orders are delivered; shipped 1.11%, canceled 0.63%, unavailable 0.61%.
SELECT order_status,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


-- Q3. Date range and uniqueness of orders
-- Finding: 99,441 unique orders, from 2016-09-04 to 2018-10-17.
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order,
       COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM orders;


-- Q4. customer_id vs customer_unique_id
-- Finding: 99,441 customer_id values but only 96,096 customer_unique_id values.
-- customer_id is generated per order; customer_unique_id identifies the real person.
-- Always use customer_unique_id for retention and repeat-purchase analysis.
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT customer_id) AS distinct_customer_id,
       COUNT(DISTINCT customer_unique_id) AS distinct_customer_unique_id
FROM customers;


-- Q5. Missing timestamps in orders
-- Finding: 160 missing approval, 1,783 missing carrier date, 2,965 missing delivery date.
SELECT COUNT(*) AS total_orders,
       COUNT(*) - COUNT(order_approved_at) AS missing_approved,
       COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
       COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date
FROM orders;


-- Q6. Missing delivery dates by order status
-- Finding: most missing dates are expected (not delivered yet or canceled).
-- Only 8 'delivered' orders have no delivery date; they are excluded from delivery calculations.
SELECT order_status,
       COUNT(*) AS orders,
       COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;
