-- Business rule: sale price must always be greater than zero
SELECT order_item_id, sale_price
FROM {{ ref('fact_sales') }}
WHERE sale_price <= 0
