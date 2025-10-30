# Databricks notebook source
from pyspark.sql.functions import *

# COMMAND ----------

# Azure Event Hub Configuration
event_hub_namespace = "HealthcareDataEngineer.servicebus.windows.net"
event_hub_name="healthcaredataengineer_eh"
event_hub_conn_str = dbutils.secrets.get(scope="hospitalflowanalytics", key="EventHubConn")


kafka_options = {
    'kafka.bootstrap.servers': f"{event_hub_namespace}:9093",
    'subscribe': event_hub_name,
    'kafka.security.protocol': 'SASL_SSL',
    'kafka.sasl.mechanism': 'PLAIN',
    'kafka.sasl.jaas.config': f'kafkashaded.org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="{event_hub_conn_str}";',
    'startingOffsets': 'latest',
    'failOnDataLoss': 'false'
}

# COMMAND ----------

raw_df = (spark.readStream.format('kafka').options(**kafka_options).load())

json_df = raw_df.selectExpr("CAST(value as STRING) as raw_json")

# COMMAND ----------

bronze_path = "abfss://bronze@healthcaredataengineerdl.dfs.core.windows.net/patient_flow"

# COMMAND ----------

(
    json_df
    .writeStream
    .format("delta")
    .outputMode("append")
    .option("checkpointLocation", "abfss://bronze@healthcaredataengineerdl.dfs.core.windows.net/patient_flow/_checkpoint")
    .trigger(once=True)
    .start(bronze_path)
)


# COMMAND ----------

display(spark.read.format('delta').load(bronze_path))