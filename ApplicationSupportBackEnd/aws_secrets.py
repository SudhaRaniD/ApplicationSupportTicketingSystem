
import json
import os

import boto3
from sqlalchemy.engine import URL


def get_rds_database_url():
    secret_arn = os.environ["RDS_SECRET_ARN"]
    endpoint = os.environ["RDS_ENDPOINT"]

    region = os.getenv("AWS_REGION", "eu-west-2")

    client = boto3.client(
        "secretsmanager",
        region_name=region
    )

    response = client.get_secret_value(
        SecretId=secret_arn
    )

    secret = json.loads(response["SecretString"])

    database_url = URL.create(
        drivername="postgresql+psycopg",
        username=secret["username"],
        password=secret["password"],
        host=endpoint,
        port=5432,
        database="application_support"
    )

    return database_url
