import json


def lambda_handler(event, context):
    print("Application Support Alert Received")

    for record in event.get("Records", []):
        message = record.get("Sns", {}).get("Message", "")

        print("SNS Message:", message)

        try:
            alert = json.loads(message)
            print("Alarm Name:", alert.get("AlarmName"))
            print("New State:", alert.get("NewStateValue"))
            print("Reason:", alert.get("NewStateReason"))
        except json.JSONDecodeError:
            print("Received a non-JSON message")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Alert processed successfully"
        })
    }

