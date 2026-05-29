SELECT
    user_id          AS customer_key,
    user_id,
    first_name,
    last_name,
    email,
    gender,
    age,
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END              AS age_bucket,
    country,
    city,
    state,
    traffic_source,
    created_at
FROM {{ ref('stg_users') }}
