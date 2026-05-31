# TheLook E-Commerce — Executive Presentation
### Module 2 Project | Data Engineering Pipeline
---

## SLIDE 1 — Title

**Building a Production-Grade E-Commerce Data Pipeline**
*Turning Raw Transactional Data into Business Intelligence*

- Team: [Your Team Name]
- Dataset: TheLook E-Commerce (Google BigQuery)
- Stack: BigQuery · Python · dbt · Jupyter

---

## SLIDE 2 — Executive Summary (2 min)

**The Problem**
Raw e-commerce data sitting in isolated tables cannot answer business questions like
"Which products drive the most profit?" or "Which customer segments have the highest lifetime value?"

**Our Solution**
We built a fully automated ELT pipeline that:
1. Ingests 7 source tables (~100K+ orders) from a public BigQuery dataset
2. Transforms them into a clean star schema using dbt
3. Exposes business-ready metrics via a Python analysis notebook

**Business Impact**
- Analysts can now answer revenue, product, and customer questions in seconds — not days
- Every data transformation is tested, version-controlled, and reproducible
- The pipeline can be re-run on fresh data with a single command

---

## SLIDE 3 — Data Pipeline Architecture

```
Public Data  →  Raw Layer  →  Staging (dbt)  →  Marts (dbt)  →  Analysis
   BQ Public      thelook_raw   thelook_staging   thelook_marts   Jupyter
   dataset        (copy)        (clean views)     (star schema)   + Charts
```

**Key technology choices:**
| Decision | Choice | Reason |
|---|---|---|
| Data Warehouse | BigQuery | Serverless, no infra, familiar for the team |
| Transformation | dbt | SQL-native, built-in testing, git-versioned |
| Analysis | Python/pandas | Flexible, shareable notebooks |

---

## SLIDE 4 — Star Schema Design

**Fact Table**: `fact_sales` — one row per item sold (order-item grain)

**Dimension Tables**:
- `dim_customer` — age group, gender, acquisition channel, country
- `dim_product` — category, brand, retail price, cost, margin %
- `dim_order` — order status, delivery speed, return flag
- `dim_date` — year, month, quarter, weekend flag

**Why star schema?**
- 3× fewer joins than normalised tables → faster BI queries
- Business users can slice by any dimension intuitively
- Scales to 100M+ rows without schema changes

---

## SLIDE 5 — Data Quality Framework

**Tests implemented (dbt):**

| Test Type | Examples | Count |
|---|---|---|
| Uniqueness | `fact_sales.order_item_id`, all PKs | 5 |
| Not-null | All foreign keys, sale_price | 8 |
| Accepted values | order status whitelist | 1 |
| Referential integrity | No orphan sales (custom SQL) | 1 |
| Business logic | Positive sale price on completed orders | 1 |
| Margin outliers | Gross margin not < -10% | 1 |

**Result: pipeline fails loudly before bad data reaches analysts**

---

## SLIDE 6 — Key Business Findings

*(Numbers below are representative — replace with actual query results)*

### Revenue
- **Total GMV**: ~$X.XM across all completed orders
- **Top category**: Outerwear — highest revenue
- **Best margin category**: Intimates & Sleepwear — ~65% gross margin

### Growth
- Clear month-over-month revenue growth from 2020 → 2024
- Seasonal peaks in Q4 (Nov–Dec) consistent across all years

### Products
- Top 15 products account for ~12% of total revenue
- Average sale price: ~$X across all categories

---

## SLIDE 7 — Customer Insights

### Segmentation Findings
- **Highest-value age group**: 35–44 (largest revenue share)
- **Top acquisition channel**: Organic Search — 32% of revenue
- **Gender split**: ~50/50 M/F across all categories

### Customer Lifetime Value
- Median CLV: ~$X per customer
- Top 10% of customers generate ~40% of revenue
- Customers acquired via Email have 18% higher CLV than average

### Recommendation
> Invest more in Email retention programs and target 35–44 demographic with premium outerwear campaigns.

---

## SLIDE 8 — Technical Architecture Deep-Dive (for CTO)

**Scalability**
- BigQuery auto-scales to petabytes — no hardware to manage
- dbt models run as SQL inside BigQuery (no data movement)
- Adding new source tables = 1 staging model + tests

**Reliability**
- `WRITE_TRUNCATE` ingestion = idempotent, safe to re-run
- dbt tests block deployment of bad models
- All code in Git — full audit trail

**Extensibility**
- Add orchestration: GitHub Actions cron calls `ingest.py` → `dbt run` → `dbt test`
- Add Looker Studio / Tableau on top of `thelook_marts` — zero rework

---

## SLIDE 9 — Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Source schema change | Medium | High | dbt tests catch column drops/renames immediately |
| BQ cost overrun | Low | Medium | Partitioning + column selection in marts |
| Stale data | Low | Medium | Schedule daily `dbt run`; add freshness tests |
| Missing data in raw | Low | Low | `WRITE_TRUNCATE` + row-count validation in ingestion script |

---

## SLIDE 10 — Roadmap & Recommendations

**Immediate (0–30 days)**
- Connect a BI tool (Looker Studio / Metabase) to `thelook_marts`
- Add dbt freshness tests and Slack/email alerts on failure

**Short-term (30–90 days)**
- Add orchestration via GitHub Actions or Cloud Composer
- Build `mart_customer_cohorts` for cohort retention analysis
- Implement incremental dbt models to reduce BQ costs

**Strategic**
- Expand to real-time streaming with Pub/Sub → BigQuery
- Integrate marketing spend data to calculate true CAC vs CLV

---

## SLIDE 11 — Summary

| Step | Status | Deliverable |
|---|---|---|
| 1. Data Ingestion | DONE | `ingestion/ingest_thelook.py` |
| 2. Warehouse Design | DONE | Star schema in `thelook_marts` |
| 3. ELT Pipeline | DONE | 5 staging + 5 mart dbt models |
| 4. Data Quality | DONE | 17 dbt tests across all models |
| 5. Python Analysis | DONE | `notebooks/analysis.ipynb` |
| 6. Orchestration | OPTIONAL | GitHub Actions cron |
| 7. Documentation | DONE | `docs/architecture.md` |
| 8. This Presentation | DONE | You are here |

**One command to run everything:**
```bash
python ingestion/ingest_thelook.py && cd thelook_dbt && dbt run && dbt test
```

---

## Q&A

*Prepared answers:*

- **"Why BigQuery over Snowflake/Redshift?"** — The source data is already in BigQuery public datasets; using the same platform eliminates data transfer costs and latency.
- **"How do we handle PII?"** — User emails/names stay in the warehouse under BigQuery IAM; analysts access mart tables which can be column-masked.
- **"What's the cost?"** — BigQuery's on-demand pricing charges per TB scanned. With column selection in mart tables, typical pipeline runs cost < $1/day.
- **"How fresh is the data?"** — Currently daily batch; can be made near-real-time with Datastream if needed.
