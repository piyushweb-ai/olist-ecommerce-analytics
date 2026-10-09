-- 06_revenue_and_products.sql
-- Goal: understand revenue, average order value (AOV) and which product categories earn the most.
-- Currency is Brazilian reais (R$).


-- Q1. Check the payments table
-- Finding: 103,886 payment rows for 99,440 orders, so an order can be paid in several parts
-- (for example voucher + card). Payments must be summed per order before computing order value.
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders,
       ROUND(AVG(payment_value), 2) AS avg_payment_row
FROM payments;


-- Q2. Monthly revenue and average order value (delivered orders, Jan 2017 - Aug 2018)
-- Order value = items + shipping (sum of payments per order).
-- Finding: AOV is stable at roughly R$146-R$170 with no clear trend, while revenue grew from
-- R$128k (Jan 2017) to about R$1.0-1.15M per month from Nov 2017. Growth came from more orders,
-- not bigger baskets. Peak month: Nov 2017 (R$1.15M).
WITH order_values AS (
    SELECT order_id, SUM(payment_value) AS order_value
    FROM payments
    GROUP BY order_id
)
SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
       COUNT(*) AS orders,
       ROUND(SUM(v.order_value), 0) AS revenue,
       ROUND(AVG(v.order_value), 2) AS avg_order_value
FROM orders o
JOIN order_values v ON o.order_id = v.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01'
GROUP BY 1
ORDER BY 1;


-- Q3. Top 10 product categories by revenue (item price only, excludes shipping)
-- Finding: health_beauty earns the most (R$1.26M), then watches_gifts (R$1.21M, highest average
-- item price at R$201 with about 36% fewer orders than health_beauty) and bed_bath_table
-- (most orders, 9,417, but a low average price of R$93).
-- Note: this query includes orders of all statuses; add a delivered filter for a stricter version.
SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       COUNT(DISTINCT oi.order_id) AS orders,
       ROUND(SUM(oi.price), 0) AS revenue,
       ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;
