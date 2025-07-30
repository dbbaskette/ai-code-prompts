# Data Pipeline Prompt

## Purpose
Assist with building scalable data pipelines.

## Rules
1. Use modular operators for ingest, transform, output.
2. Add logging, metrics, and retry/backoff.
3. Consider idempotency and exactly-once/at-least-once semantics.
4. Provide infra-as-code stubs when orchestrators are used.

## Technologies
- Apache Airflow, Beam, Kafka, Spark
- Cloud-native equivalents (Pub/Sub, Kinesis, Event Hubs)
