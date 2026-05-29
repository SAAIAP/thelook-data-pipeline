-- Business rule: flag items sold below cost (>$1 tolerance)
SELECT order_item_id, sale_price, cost, gross_margin
FROM {{ ref('fact_sales') }}
WHERE gross_margin < -1
