-- 02_orders_and_customers.sql
-- Goal: understand order volume over time and how often customers come back.


-- Q1. Orders per month
-- Finding: very little data before Jan 2017 and after Aug 2018 (dataset cut-off), so the
-- analysis window is Jan 2017 - Aug 2018. Peak month is Nov 2017 (7,544 orders, Black Friday).
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;


-- Q2. How many orders does each real customer place? (JOIN + CTE + window function)
-- Finding: 96.88% of customers (93,099) ordered only once; 2.86% ordered twice.
-- Only about 3% of customers ever come back: growth is driven by new customers.
WITH per_customer AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT orders,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM per_customer
GROUP BY orders
ORDER BY orders;
