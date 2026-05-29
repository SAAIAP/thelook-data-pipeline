-- Business rule: shipping must not exceed 60 days
SELECT order_item_id, days_to_ship
FROM {{ ref('fact_sales') }}
WHERE days_to_ship IS NOT NULL
  AND days_to_ship > 60
