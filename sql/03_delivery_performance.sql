-- 03_delivery_performance.sql
-- Goal: measure how long delivery takes, how often it is late, and where late deliveries concentrate.
-- All queries use delivered orders that have a delivery date.
-- "Late" means delivered after the estimated delivery date.


-- Q1. Average time spent in each stage of an order
-- Finding: purchase->approval 10.3 hours, approval->carrier 2.8 days, carrier->customer 9.3 days,
-- total 12.6 days. Shipping is about 74% of total delivery time.
SELECT
  ROUND(AVG(epoch(order_approved_at) - epoch(order_purchase_timestamp)) / 3600, 1) AS avg_hours_purchase_to_approval,
  ROUND(AVG(epoch(order_delivered_carrier_date) - epoch(order_approved_at)) / 86400, 1) AS avg_days_approval_to_carrier,
  ROUND(AVG(epoch(order_delivered_customer_date) - epoch(order_delivered_carrier_date)) / 86400, 1) AS avg_days_carrier_to_customer,
  ROUND(AVG(epoch(order_delivered_customer_date) - epoch(order_purchase_timestamp)) / 86400, 1) AS avg_total_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- Q2. Share of orders delivered later than estimated
-- Finding: 7,826 of 96,470 delivered orders (8.11%) were late.
SELECT COUNT(*) AS delivered_orders,
       SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- Q3. Late delivery rate by purchase month (Jan 2017 - Aug 2018)
-- Finding: worst months were Mar 2018 (21.36%), Feb 2018 (15.99%) and Nov 2017 (14.31%).
-- Nov 2017 matches the Black Friday volume peak; Feb-Mar 2018 had normal volume and need investigation.
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
       COUNT(*) AS delivered_orders,
       ROUND(100.0 * AVG(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END), 2) AS pct_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY 1
ORDER BY 1;


-- Q4. Late delivery rate by customer state (states with at least 500 orders, top 10)
-- Finding: highest rates in MA (19.67%), CE (15.32%), BA (14.04%) and RJ (13.47%).
-- Most are in the north and northeast; distance from sellers is a likely factor (to be checked).
SELECT c.customer_state,
       COUNT(*) AS delivered_orders,
       ROUND(100.0 * AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                              THEN 1 ELSE 0 END), 2) AS pct_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 500
ORDER BY pct_late DESC
LIMIT 10;


-- Q5. Late orders by state, ranked by number of late orders (impact = rate x volume)
-- Finding: SP has the most late orders (2,387) but a low rate (5.89%) because of volume.
-- RJ is second (1,664 late orders, 13.47% rate): the highest-impact place to improve.
-- Bringing RJ down to SP's late rate would remove roughly 930 late orders (about 12% of all late orders).
SELECT c.customer_state,
       COUNT(*) AS delivered_orders,
       SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                              THEN 1 ELSE 0 END), 2) AS pct_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_orders DESC
LIMIT 10;
