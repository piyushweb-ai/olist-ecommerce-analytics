-- 04_reviews_and_satisfaction.sql
-- Goal: link delivery performance to customer satisfaction.
-- Some orders have more than one review, so scores are averaged per order before joining.


-- Q1. Check the reviews table for duplicate reviews per order
-- Finding: 99,224 reviews for 98,673 distinct orders (551 extra reviews).
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM reviews;


-- Q2. Distribution of review scores
-- Finding: 57.78% are 5 stars and 11.51% are 1 star (polarized ratings).
SELECT review_score,
       COUNT(*) AS reviews,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- Q3. Average review score, late vs on-time orders
-- Finding: late orders average 2.57 stars vs 4.29 for on-time orders (a 1.72 point gap).
WITH order_reviews AS (
    SELECT order_id, AVG(review_score) AS score
    FROM reviews
    GROUP BY order_id
),
delivered AS (
    SELECT order_id,
           CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'late' ELSE 'on_time' END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT d.delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(r.score), 2) AS avg_review_score
FROM delivered d
JOIN order_reviews r ON d.order_id = r.order_id
GROUP BY d.delivery_status;


-- Q4. Review score by how many days late
-- Finding: on time 4.29 | 1-3 days late 3.77 | 4-7 days late 2.32 | 8+ days late 1.73.
-- Even a short delay costs about half a star; after about a week customers are near 1 star.
WITH order_reviews AS (
    SELECT order_id, AVG(review_score) AS score
    FROM reviews
    GROUP BY order_id
),
delivered AS (
    SELECT order_id,
           (epoch(order_delivered_customer_date) - epoch(order_estimated_delivery_date)) / 86400 AS days_late
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT CASE WHEN days_late <= 0 THEN '1_on_time'
            WHEN days_late <= 3 THEN '2_1-3_days_late'
            WHEN days_late <= 7 THEN '3_4-7_days_late'
            ELSE '4_8plus_days_late' END AS lateness,
       COUNT(*) AS orders,
       ROUND(AVG(r.score), 2) AS avg_review_score
FROM delivered d
JOIN order_reviews r ON d.order_id = r.order_id
GROUP BY 1
ORDER BY 1;


-- Q5. Share of low reviews (1-2 stars), late vs on-time
-- Finding: 53.99% of late orders get a low review vs 9.19% of on-time orders (about 6x more likely).
WITH order_reviews AS (
    SELECT order_id, AVG(review_score) AS score
    FROM reviews
    GROUP BY order_id
),
delivered AS (
    SELECT order_id,
           CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'late' ELSE 'on_time' END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT d.delivery_status,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(CASE WHEN r.score <= 2 THEN 1 ELSE 0 END), 2) AS pct_low_reviews
FROM delivered d
JOIN order_reviews r ON d.order_id = r.order_id
GROUP BY d.delivery_status;


-- Q6. Of all low-review orders, what share were delivered late?
-- Finding: 33.8% (4,136 of 12,236) although late orders are only about 8% of all orders.
WITH order_reviews AS (
    SELECT order_id, AVG(review_score) AS score
    FROM reviews
    GROUP BY order_id
),
delivered AS (
    SELECT order_id,
           CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'late' ELSE 'on_time' END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT COUNT(*) AS low_review_orders,
       SUM(CASE WHEN d.delivery_status = 'late' THEN 1 ELSE 0 END) AS late_among_them,
       ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'late' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late_among_low
FROM delivered d
JOIN order_reviews r ON d.order_id = r.order_id
WHERE r.score <= 2;
