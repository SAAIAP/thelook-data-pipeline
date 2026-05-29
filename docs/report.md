# Technical Report — TheLook Data Pipeline

## 1. Executive Summary
End-to-end ELT pipeline ingesting thelook_ecommerce (250K+ order items) into a BigQuery
star schema, transformed via dbt Core, quality-tested with 21 automated checks, and
analysed with Python/pandas. Orchestrated daily by GitHub Actions.

## 2. Architecture
Source → Python ingest → thelook_raw.* → dbt staging (views) → dbt marts (tables) → Jupyter analysis

## 3. Tool Selection Rationale

| Decision         | Choice            | Reason                                                       |
|------------------|-------------------|--------------------------------------------------------------|
| Warehouse        | BigQuery          | Serverless, columnar, native home of public dataset          |
| Transformation   | dbt Core          | SQL-native, lineage DAG, built-in test framework, open source|
| Orchestration    | GitHub Actions    | Zero infra, free tier, lives in repo                         |
| Analysis         | pandas + seaborn  | Reproducible notebooks, full Python ecosystem                |

## 4. Schema Design Justification
- Star schema over 3NF: optimised for read-heavy analytical workloads with fewer joins
- Order-item grain in fact_sales: enables product-level metrics impossible at order grain
- Pre-computed measures (gross_margin, days_to_ship): eliminate repeated downstream calculation
- dim_date as generated table: enables any time-grain grouping without string parsing overhead

## 5. Data Quality Findings
- 21 tests across 4 categories: null, uniqueness, referential integrity, business rules
- Known anomaly: ~12 items where sale_price < cost — source data issue, documented and
  excluded from margin KPIs. Not a pipeline bug.

## 6. Key Insights
- Revenue grows 34% YoY with clear Nov-Dec seasonal peak (28% of annual revenue)
- Outerwear and Jeans drive 47% of total revenue
- Top 12% of customers (Champions) generate 38% of revenue — protect with loyalty programmes
- At Risk segment (35%) represents ~$880K recoverable revenue via re-engagement campaigns
- Luxury tier carries 58% gross margin vs 22% Budget — opportunity to shift product mix

## 7. Limitations and Future Improvements
- Incremental dbt models (currently full refresh — cost concern at scale)
- Add Looker Studio dashboard connected directly to BigQuery
- Expand RFM to a churn prediction model (scikit-learn)
- Migrate orchestration to Dagster for richer asset-based observability
- Add dbt Exposures to document which dashboards consume which models
