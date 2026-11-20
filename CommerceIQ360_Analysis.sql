
USE commerceiq360;

-- 1. Overall business performance
-- First, I checked the total orders, items sold, revenue and average rating.
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(quantity * unit_price_usd - discount_usd), 2) AS total_revenue,
    ROUND(AVG(review_score), 2) AS average_review_score
FROM orders;


-- 2. Monthly sales analysis
-- This helps to understand how sales change from month to month.
SELECT
    DATE_FORMAT(
        STR_TO_DATE(order_date, '%Y-%m-%d'), '%Y-%m'
    ) AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(quantity * unit_price_usd - discount_usd), 2) AS revenue
FROM orders
GROUP BY sales_month
ORDER BY sales_month;


-- 3. Sales by product category
-- I used this query to find which product categories perform best.
SELECT
    product_category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(quantity * unit_price_usd - discount_usd), 2) AS revenue
FROM orders
GROUP BY product_category
ORDER BY revenue DESC;


-- 4. Sales across different regions
-- This gives an idea of which customer regions generate more sales.
SELECT
    customer_region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(quantity * unit_price_usd - discount_usd), 2) AS revenue
FROM orders
GROUP BY customer_region
ORDER BY revenue DESC;


-- 5. Order status analysis
-- This shows how many orders are delivered, cancelled or in other statuses.
SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 6. Delivery performance
-- Here I compared actual delivery dates with promised delivery dates.
-- Negative delay means early delivery, while positive delay means late delivery.
SELECT
    COUNT(*) AS delivered_items,
    SUM(
        CASE
            WHEN DATEDIFF(
                STR_TO_DATE(actual_delivery_date, '%Y-%m-%d'),
                STR_TO_DATE(promised_delivery_date, '%Y-%m-%d')
            ) <= 0 THEN 1
            ELSE 0
        END
    ) AS on_time_items,
    ROUND(AVG(
        DATEDIFF(
            STR_TO_DATE(actual_delivery_date, '%Y-%m-%d'),
            STR_TO_DATE(promised_delivery_date, '%Y-%m-%d')
        )
    ), 2) AS average_delay_days
FROM orders
WHERE LOWER(TRIM(order_status)) = 'delivered'
  AND actual_delivery_date IS NOT NULL
  AND promised_delivery_date IS NOT NULL
  AND actual_delivery_date <> ''
  AND promised_delivery_date <> '';


-- 7. Delivery partner performance
-- This helps compare delivery partners based on their average delivery delay.
SELECT
    delivery_partner,
    COUNT(*) AS delivered_items,
    ROUND(AVG(
        DATEDIFF(
            STR_TO_DATE(actual_delivery_date, '%Y-%m-%d'),
            STR_TO_DATE(promised_delivery_date, '%Y-%m-%d')
        )
    ), 2) AS average_delay_days
FROM orders
WHERE LOWER(TRIM(order_status)) = 'delivered'
  AND actual_delivery_date IS NOT NULL
  AND promised_delivery_date IS NOT NULL
  AND actual_delivery_date <> ''
  AND promised_delivery_date <> ''
GROUP BY delivery_partner
ORDER BY average_delay_days DESC;


-- 8. Payment method analysis
-- I checked which payment methods are used more often and generate more revenue.
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(quantity * unit_price_usd - discount_usd), 2) AS revenue
FROM orders
GROUP BY payment_method
ORDER BY revenue DESC;


-- 9. Customer review analysis
-- This shows the number of different orders receiving each review score.
SELECT
    review_score,
    COUNT(DISTINCT order_id) AS reviewed_orders
FROM orders
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score;


-- 10. Fulfilment centre performance
-- This helps identify fulfilment centres with higher delivery delays.
SELECT
    fulfillment_center,
    COUNT(*) AS delivered_items,
    ROUND(AVG(
        DATEDIFF(
            STR_TO_DATE(actual_delivery_date, '%Y-%m-%d'),
            STR_TO_DATE(promised_delivery_date, '%Y-%m-%d')
        )
    ), 2) AS average_delay_days
FROM orders
WHERE LOWER(TRIM(order_status)) = 'delivered'
  AND actual_delivery_date IS NOT NULL
  AND promised_delivery_date IS NOT NULL
  AND actual_delivery_date <> ''
  AND promised_delivery_date <> ''
GROUP BY fulfillment_center
ORDER BY average_delay_days DESC;
