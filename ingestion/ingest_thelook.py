"""
Step 1 — Data Ingestion
Copies thelook_ecommerce tables from the BigQuery public dataset
into your own project under the thelook_raw dataset.
"""

from google.cloud import bigquery

PROJECT_ID     = "ntupace"          # ← replace
SOURCE_PROJECT = "bigquery-public-data"
SOURCE_DATASET = "thelook_ecommerce"
TARGET_DATASET = "thelook_raw"

TABLES = [
    "orders",
    "order_items",
    "products",
    "users",
    "inventory_items",
    "events",
    "distribution_centers",
]


def ingest():
    client = bigquery.Client(project=PROJECT_ID)

    # Ensure the destination dataset exists
    dataset_ref = f"{PROJECT_ID}.{TARGET_DATASET}"
    try:
        client.get_dataset(dataset_ref)
        print(f"Dataset {TARGET_DATASET} already exists.")
    except Exception:
        client.create_dataset(
            bigquery.Dataset(dataset_ref), exists_ok=True
        )
        print(f"✓ Created dataset {TARGET_DATASET}")

    # Copy each table
    for table in TABLES:
        source = f"{SOURCE_PROJECT}.{SOURCE_DATASET}.{table}"
        target = f"{PROJECT_ID}.{TARGET_DATASET}.{table}"

        job_config = bigquery.CopyJobConfig(
            write_disposition="WRITE_TRUNCATE"  # overwrite on re-run
        )

        job = client.copy_table(source, target, job_config=job_config)
        job.result()
        print(f"  ✓ {table}")

    print("\nIngestion complete.")

    # Row-count verification
    print("\n=== Row counts ===")
    for table in TABLES:
        q = f"SELECT COUNT(*) AS cnt FROM `{PROJECT_ID}.{TARGET_DATASET}.{table}`"
        rows = list(client.query(q).result())
        print(f"  {table:<25} {rows[0].cnt:>10,}")


if __name__ == "__main__":
    ingest()
