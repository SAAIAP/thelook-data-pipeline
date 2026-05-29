WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
    WHERE status NOT IN ('cancelled', 'returned')
),
orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
products AS (
    SELECT * FROM {{ ref('stg_products') }}
)

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id                                                      AS product_key,
    o.user_id                                                          AS customer_key,
    CAST(FORMAT_DATE('%Y%m%d', DATE(o.created_at)) AS INT64)           AS date_key,
    oi.status,
    oi.sale_price,
    p.cost,
    ROUND(oi.sale_price - p.cost, 2)                                   AS gross_margin,
    ROUND(p.retail_price - oi.sale_price, 2)                           AS discount_amount,
    ROUND(SAFE_DIVIDE(oi.sale_price - p.cost, oi.sale_price), 4)       AS gross_margin_pct,
    SUM(oi.sale_price) OVER (
        PARTITION BY o.user_id
        ORDER BY o.created_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                                   AS customer_running_revenue,
    o.created_at,
    oi.shipped_at,
    oi.delivered_at,
    DATE_DIFF(DATE(oi.shipped_at), DATE(o.created_at), DAY)            AS days_to_ship
FROM order_items oi
JOIN orders   o ON oi.order_id   = o.order_id
JOIN products p ON oi.product_id = p.product_id
