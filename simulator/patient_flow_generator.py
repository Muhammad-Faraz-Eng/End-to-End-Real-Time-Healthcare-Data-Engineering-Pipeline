from kafka import KafkaProducer
import json, random, time
from datetime import datetime, timedelta, UTC

# -------------------------------
# 🔧 Azure Event Hub Configuration
# -------------------------------

EVENT_HUB_FQDN = "<<PlaceHolder>>" 
EVENT_HUB_NAME = "<<PlaceHolder>>" 
SAS_KEY_NAME = "<<PlaceHolder>>" 
SAS_KEY = "<<PlaceHolder>>"  

bootstrap_server = f"{EVENT_HUB_FQDN}:9093"
username = "$ConnectionString"
password = (
    f"Endpoint=sb://{EVENT_HUB_FQDN}/;"
    f"SharedAccessKeyName={SAS_KEY_NAME};"
    f"SharedAccessKey={SAS_KEY}"
)

# ---------------------------------------
# 🚀 Initialize Kafka Producer Connection
# ---------------------------------------
producer = KafkaProducer(
    bootstrap_servers=bootstrap_server,
    security_protocol="SASL_SSL",
    sasl_mechanism="PLAIN",
    sasl_plain_username=username,
    sasl_plain_password=password,
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
)

print("✅ Connected successfully! Starting real-time patient data stream...")

# ---------------------------------------
# 🏥 Domain Data Categories
# ---------------------------------------
departments = ["Emergency", "Surgery", "ICU", "Pediatrics", "Maternity", "Oncology", "Cardiology"]
statuses = ["admitted", "discharged", "under_treatment", "awaiting_tests"]
genders = ["Male", "Female"]

# ---------------------------------------
# 🔁 Continuous Event Stream Generator
# ---------------------------------------
try:
    counter = 0
    while True:
        # Simulate random admission and discharge times
        admission_time = datetime.now(UTC) - timedelta(hours=random.randint(0, 72))
        discharge_time = admission_time + timedelta(hours=random.randint(1, 72))

        # Generate random event record
        event = {
            "patient_id": random.randint(1000, 9999),
            "gender": random.choice(genders),
            "department": random.choice(departments),
            "status": random.choice(statuses),
            "admission_time": admission_time.isoformat(),
            "discharge_time": discharge_time.isoformat(),
            "timestamp": datetime.now(UTC).isoformat(),
            "bed_id": random.randint(1, 500),
            "hospital_id": random.randint(1, 7),
            "age": random.randint(1, 100)
        }

        # Send event to Event Hub
        producer.send(EVENT_HUB_NAME, value=event)
        counter += 1
        print(f"✅ Sent event #{counter}: {event}")

        time.sleep(1)  # ⏱️ One event per second

except KeyboardInterrupt:
    print("\n🛑 Streaming stopped by user.")
    print(f"📊 Total events sent: {counter}")

finally:
    producer.flush()
    producer.close()
    print("🔒 Producer connection closed.")
