# Pipeline Architecture — TheLook E-Commerce

## Stack

| Layer | Tool | Why chosen |
|---|---|---|
| Data warehouse | Google BigQuery | Serverless, petabyte-scale, public dataset already hosted here |
| Ingestion | Python + `google-cloud-bigquery` SDK | `copy_table` API is idempotent and zero-infra for a BQ-to-BQ copy |
| Transformation | dbt (BigQuery adapter) | SQL-native ELT, built-in testing, git-versioned lineage |
| Data quality | dbt schema tests + singular SQL tests | Inline with transforms — no extra tooling at this scale |
| Analysis | Python (pandas + SQLAlchemy + matplotlib) | Reproducible, shareable Jupyter notebooks |
| Orchestration | GitHub Actions cron | Zero-infra; triggers ingest → dbt run → dbt test on schedule |

## Data Flow

```
┌─────────────────────────────────────┐
│  bigquery-public-data               │
│  .thelook_ecommerce                 │
│  (orders, order_items, products,    │
│   users, inventory_items, events,   │
│   distribution_centers)             │
└──────────────┬──────────────────────┘
               │  Python copy_table (WRITE_TRUNCATE)
               ▼
┌─────────────────────────────────────┐
│  ntupace.thelook_raw                │  ← exact copy, no transformations
└──────────────┬──────────────────────┘
               │  dbt staging models (materialized as views)
               ▼
┌─────────────────────────────────────┐
│  ntupace.thelook_staging            │
│  stg_orders                         │
│  stg_order_items                    │
│  stg_products                       │
│  stg_users                          │
│  stg_distribution_centers           │
└──────────────┬──────────────────────┘
               │  dbt mart models (materialized as tables)
               ▼
┌─────────────────────────────────────┐
│  ntupace.thelook_marts  (star schema)│
│                                     │
│  dim_customer ──┐                   │
│  dim_product  ──┤                   │
│  dim_date     ──┼── fact_sales      │
└─────────────────────────────────────┘
               │  SQLAlchemy + pandas
               ▼
┌─────────────────────────────────────┐
│  notebooks/analysis.ipynb           │  ← charts + business insights
└─────────────────────────────────────┘
```

## Star Schema

```
              ┌─────────────┐
              │  dim_date   │
              │  date_key   │
              │  year/month │
              │  quarter    │
              └──────┬──────┘
                     │ date_key
┌────────────────┐   ┌┴────────────────────────────────────┐   ┌──────────────────┐
│  dim_customer  │   │           fact_sales                 │   │   dim_product    │
│  customer_key  ├───┤  order_item_id  (PK)                 ├───┤  product_key     │
│  user_id       │   │  customer_key   (FK)                 │   │  product_id      │
│  age_bucket    │   │  product_key    (FK)                 │   │  name / category │
│  gender        │   │  date_key       (FK)                 │   │  brand           │
│  country       │   │  sale_price                         │   │  price_tier      │
│  traffic_source│   │  cost                               │   │  margin_pct      │
└────────────────┘   │  gross_margin                       │   └──────────────────┘
                     │  gross_margin_pct                   │
                     │  discount_amount                    │
                     │  days_to_ship                       │
                     │  customer_running_revenue           │
                     └─────────────────────────────────────┘
```

## Schema Design Justification

- **Star schema** over 3NF: fewer joins, faster OLAP queries, easier for BI tools
- `fact_sales` at **order-item grain**: finest granularity, supports roll-up to any level
- `customer_key` / `product_key` surrogate keys: decouple mart from source ID changes
- `price_tier` in `dim_product`: pre-computed label avoids repeated CASE logic in queries
- `customer_running_revenue` in `fact_sales`: window function pre-computed at transform time
- Staging as **views** (no storage cost); marts as **tables** (fast query performance)

## Running the Pipeline

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Ingest raw data into BigQuery
python ingestion/ingest_thelook.py

# 3. Install dbt packages
cd thelook_dbt && dbt deps

# 4. Run all dbt models
dbt run

# 5. Run all data quality tests
dbt test

# 6. Open analysis notebook
cd .. && jupyter notebook notebooks/analysis.ipynb
```

## CI/CD (GitHub Actions)

See `.github/workflows/pipeline.yml` — triggers on push and on daily cron schedule.
