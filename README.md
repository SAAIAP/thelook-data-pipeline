# TheLook E-Commerce Data Pipeline

End-to-end data engineering project using the `thelook_ecommerce` public BigQuery dataset.

## Architecture

```
BigQuery Public Data → Python Ingest → thelook_raw → dbt ELT → thelook_warehouse → Jupyter Analysis
                                                                        ↑
                                                              GitHub Actions (daily @ 3am UTC)
```

## Tech Stack

| Layer         | Tool                            |
|---------------|---------------------------------|
| Source        | BigQuery public dataset          |
| Ingestion     | Python + google-cloud-bigquery   |
| Warehouse     | BigQuery (star schema)           |
| Transformation| dbt Core                        |
| Quality       | dbt test + custom SQL (21 tests) |
| Analysis      | Jupyter + pandas + seaborn       |
| Orchestration | GitHub Actions (daily cron)      |

## Project Structure

```
├── ingestion/              # Step 1 – raw data copy scripts
├── thelook_dbt/            # Steps 2–4 – dbt models
│   ├── models/staging/     # stg_* views (cleaning)
│   ├── models/marts/       # dim_* and fact_* tables
│   └── tests/              # singular SQL quality tests
├── tests/                  # Python quality report
├── notebooks/              # analysis.ipynb
├── reports/                # generated charts
├── docs/                   # architecture + technical report
└── .github/workflows/      # CI/CD orchestration
```

## Quickstart

```bash
# 1. Authenticate
gcloud auth application-default login

# 2. Ingest raw data
python ingestion/ingest_thelook.py

# 3. Run dbt pipeline
cd thelook_dbt && dbt run && dbt test

# 4. Run analysis
jupyter notebook notebooks/analysis.ipynb
```

## Schema Design

Star schema centred on `fact_sales` at order-item grain.
Dimension tables: `dim_customer`, `dim_product`, `dim_date`.
Pre-computed measures: `gross_margin`, `discount_amount`, `days_to_ship`.

## Data Quality

21 automated tests: null checks, uniqueness, referential integrity, business rules.
See `tests/quality_report.py` for the Python summary report.
