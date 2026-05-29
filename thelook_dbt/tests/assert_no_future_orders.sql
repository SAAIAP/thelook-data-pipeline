-- Business rule: no order date should be in the future
SELECT order_item_id, created_at
FROM {{ ref('fact_sales') }}
WHERE DATE(created_at) > CURRENT_DATE()
