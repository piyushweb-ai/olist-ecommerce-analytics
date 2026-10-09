-- 05_retention.sql
-- Goal: measure repeat purchases and cohort retention using customer_unique_id (the real person).
-- Canceled and unavailable orders are excluded.


-- Q1. Does a late first delivery reduce repeat purchases?
-- Uses ROW_NUMBER() to find each customer's first order and COUNT() OVER to count total orders.
-- Only first orders placed in 2017 are used, so every customer has at least 8 months to come back.
-- Finding: first order on time -> about 4.3% place a second order; first order late -> about 3.0%.
-- The difference was tested in Python (two-proportion z-test, p = 0.0013, 95% CI of the gap
-- roughly -1.9 to -0.6 percentage points). Observational data: shows association, not proof of cause.
-- order_id is added as a tiebreaker so customers with identical timestamps are handled consistently.
WITH orders_c AS (
    SELECT c.customer_unique_id,
           o.order_id,
           o.order_status,
           o.order_purchase_timestamp,
           o.order_delivered_customer_date,
           o.order_estimated_delivery_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_unique_id
                              ORDER BY order_purchase_timestamp, order_id) AS rn,
           COUNT(*) OVER (PARTITION BY customer_unique_id) AS total_orders
    FROM orders_c
)
SELECT CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'late' ELSE 'on_time' END AS first_order_delivery,
       COUNT(*) AS customers,
       SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeaters,
       ROUND(100.0 * AVG(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END), 2) AS repeat_rate_pct
FROM ranked
WHERE rn = 1
  AND order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-01-01'
GROUP BY 1;


-- Q2. Monthly cohort retention (cohort = month of first purchase), months 0-6
-- Finding: month-1 retention is mostly 0.4%-0.7% and later months hover around 0.2%-0.4%.
-- Customers do not build a buying habit; growth depends on acquiring new customers.
-- Note: the Aug 2018 cohort is unreliable because the dataset ends shortly after, so it is excluded
-- from the heatmap. Early cohorts are small, so single cells are noisy.
WITH orders_c AS (
    SELECT c.customer_unique_id,
           DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
first_month AS (
    SELECT customer_unique_id, MIN(order_month) AS cohort_month
    FROM orders_c
    GROUP BY 1
),
activity AS (
    SELECT f.cohort_month,
           date_diff('month', f.cohort_month, o.order_month) AS month_offset,
           COUNT(DISTINCT o.customer_unique_id) AS active_customers
    FROM orders_c o
    JOIN first_month f USING (customer_unique_id)
    GROUP BY 1, 2
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS size
    FROM first_month
    GROUP BY 1
)
SELECT a.cohort_month,
       s.size,
       a.month_offset,
       a.active_customers,
       ROUND(100.0 * a.active_customers / s.size, 2) AS retention_pct
FROM activity a
JOIN cohort_size s USING (cohort_month)
WHERE a.cohort_month >= '2017-01-01'
  AND a.cohort_month <  '2018-09-01'
  AND a.month_offset BETWEEN 0 AND 6
ORDER BY 1, 3;
