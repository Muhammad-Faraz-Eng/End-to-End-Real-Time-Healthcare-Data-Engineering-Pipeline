from kafka import KafkaProducer
import json, random, time
from datetime import datetime, timedelta, UTC

# Event Hub Configuration
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

# Initialize Kafka Producer
producer = KafkaProducer(
    bootstrap_servers=bootstrap_server,
    security_protocol="SASL_SSL",
    sasl_mechanism="PLAIN",
    sasl_plain_username=username,
    sasl_plain_password=password,
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
)

print("✅ Connected successfully! Starting real-time patient data stream...")

# Departments and statuses
departments = ["Emergency", "Surgery", "ICU", "Pediatrics", "Maternity", "Oncology", "Cardiology"]
statuses = ["admitted", "discharged", "under_treatment", "awaiting_tests"]

try:
    counter = 0
    while True:
        # Simulate event
        event = {
            "patient_id": random.randint(1000, 9999),
            "department": random.choice(departments),
            "status": random.choice(statuses),
            "admission_time": (datetime.now(UTC) - timedelta(hours=random.randint(0, 48))).isoformat(),
            "timestamp": datetime.now(UTC).isoformat()
        }

        # Send event to Event Hub
        producer.send(EVENT_HUB_NAME, value=event)
        counter += 1
        print(f"✅ Sent event #{counter}: {event}")

        time.sleep(1)  # Send one event every second

except KeyboardInterrupt:
    print("\n🛑 Streaming stopped by user.")
    print(f"📊 Total events sent: {counter}")

finally:
    producer.flush()
    producer.close()
    print("🔒 Producer connection closed.")
