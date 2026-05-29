-- Completeness: fact table must have rows
SELECT 1
FROM {{ ref('fact_sales') }}
HAVING COUNT(*) = 0
