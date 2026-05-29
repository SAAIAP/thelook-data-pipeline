"""
Step 4 — Data Quality Report
Runs SQL-based checks against the warehouse layer and prints a summary.
"""
from google.cloud import bigquery
import pandas as pd

PROJECT = "ntupace"   # ← replace
WH      = "thelook_warehouse"
client  = bigquery.Client(project=PROJECT)

checks = {
    "fact_sales row count":     f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales`",
    "null customer_keys":       f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales` WHERE customer_key IS NULL",
    "null product_keys":        f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales` WHERE product_key IS NULL",
    "orphan product_keys":      f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales` f LEFT JOIN `{PROJECT}.{WH}.dim_product` p ON f.product_key=p.product_key WHERE p.product_key IS NULL",
    "orphan customer_keys":     f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales` f LEFT JOIN `{PROJECT}.{WH}.dim_customer` c ON f.customer_key=c.customer_key WHERE c.customer_key IS NULL",
    "negative sale prices":     f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales` WHERE sale_price <= 0",
    "sales below cost":         f"SELECT COUNT(*) AS cnt FROM `{PROJECT}.{WH}.fact_sales` WHERE gross_margin < -1",
    "duplicate order_item_ids": f"SELECT COUNT(*) AS cnt FROM (SELECT order_item_id FROM `{PROJECT}.{WH}.fact_sales` GROUP BY 1 HAVING COUNT(*)>1)",
}

results = []
for check, query in checks.items():
    val = list(client.query(query).result())[0]["cnt"]
    if check == "fact_sales row count":
        status = "PASS" if val > 0 else "FAIL"
    else:
        status = "PASS" if val == 0 else f"FAIL ({val:,} violations)"
    results.append({"Check": check, "Value": val, "Status": status})

df = pd.DataFrame(results)
print("\n=== Data Quality Report ===")
print(df.to_string(index=False))
print(f"\nPassed: {sum(1 for r in results if 'PASS' in r['Status'])} / {len(results)}")
df.to_csv("reports/quality_report.csv", index=False)
print("Saved -> reports/quality_report.csv")
