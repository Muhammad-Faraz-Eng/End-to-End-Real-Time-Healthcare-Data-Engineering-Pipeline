# 🏥 End-to-End Real-Time Healthcare Data Engineering Pipeline

## 🚀 Project Overview
This project demonstrates a **real-time data pipeline** for healthcare analytics using **Azure Data Engineering tools**.  
We simulate patient flow events, stream them via **Azure Event Hubs (Kafka interface)**, process data using **Azure Databricks (PySpark)**, store them in **Delta Lake** following the **Medallion Architecture (Bronze, Silver, Gold)**, and finally load the transformed data into **Azure Synapse Analytics** for visualization in **Power BI**.

---

## 🧠 Key Concepts & Tools

### 🔹 Azure Services
- **Azure Event Hubs** – Real-time event streaming (Kafka-compatible)
- **Azure Databricks** – Data transformation using PySpark
- **Azure Data Factory** – Pipeline orchestration and scheduling
- **Azure Synapse Analytics** – Data warehousing and reporting
- **Power BI** – Business intelligence and visualization

### 🔹 Data Architecture
- **Medallion Architecture**
  - 🟤 **Bronze Layer** → Raw data ingestion  
  - ⚪ **Silver Layer** → Data cleansing and enrichment  
  - 🟡 **Gold Layer** → Aggregated business-ready data

- **Delta Lake** for ACID transactions, schema enforcement, and time travel  
- **Star Schema** with **Fact & Dimension tables**  
- **SCD Type 2** implementation in the Gold layer for historical tracking

---

## 📊 Pipeline Flow

```mermaid
graph TD
A[Patient Flow Data Generator] -->|Kafka| B[Azure Event Hub]
B --> C[Databricks - Bronze Layer]
C --> D[Databricks - Silver Layer]
D --> E[Databricks - Gold Layer]
E --> F[Azure Synapse SQL Pool]
F --> G[Power BI Dashboard]


🧩 Components

| Layer          | Technology        | Description                                   |
| -------------- | ----------------- | --------------------------------------------- |
| Data Source    | Python + Kafka    | Simulated real-time patient flow events       |
| Ingestion      | Azure Event Hub   | Streams data to Databricks                    |
| Transformation | Azure Databricks  | Cleansing, enrichment, and schema evolution   |
| Storage        | Delta Lake        | Managed Medallion architecture layers         |
| Warehouse      | Synapse Analytics | Star schema for analytics                     |
| Visualization  | Power BI          | Real-time dashboard for patient flow insights |


📂 Project Structure


📦 healthcare-data-engineering-pipeline
 ┣ 📁 data_generator
 ┃ ┗ 📜 patient_flow_generator.py
 ┣ 📁 notebooks
 ┃ ┣ 📜 bronze_ingestion.ipynb
 ┃ ┣ 📜 silver_transformation.ipynb
 ┃ ┣ 📜 gold_aggregation.ipynb
 ┣ 📁 synapse
 ┃ ┗ 📜 create_star_schema.sql
 ┣ 📁 docs
 ┃ ┗ 📜 architecture_diagram.png
 ┣ 📜 azure_data_factory_pipeline.json
 ┣ 📜 requirements.txt
 ┗ 📜 README.md
