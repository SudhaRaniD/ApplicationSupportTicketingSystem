# from sqlalchemy import create_engine
# from sqlalchemy.orm import sessionmaker, declarative_base

# DATABASE_URL = "sqlite:///./tickets.db"

# engine = create_engine(
#     DATABASE_URL,
#     connect_args={"check_same_thread": False}
# )

# SessionLocal = sessionmaker(
#     autocommit=False,
#     autoflush=False,
#     bind=engine
# )

# Base = declarative_base()



# import os

# from sqlalchemy import create_engine
# from sqlalchemy.orm import sessionmaker, declarative_base

# DATABASE_URL = os.getenv(
#     "DATABASE_URL",
#     "sqlite:///./tickets.db"
# )

# connect_args = {}

# if DATABASE_URL.startswith("sqlite"):
#     connect_args = {"check_same_thread": False}

# engine = create_engine(
#     DATABASE_URL,
#     connect_args=connect_args,
#     pool_pre_ping=True
# )

# SessionLocal = sessionmaker(
#     autocommit=False,
#     autoflush=False,
#     bind=engine
# )

# Base = declarative_base()

import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# DATABASE_URL = os.getenv(
#     "DATABASE_URL",
#     "sqlite:///./tickets.db"
# )


import os

# AWS deployment requires PostgreSQL
APP_ENV = os.getenv("APP_ENV", "local")

if APP_ENV == "aws":
    if not os.getenv("RDS_ENDPOINT"):
        raise RuntimeError(
            "RDS_ENDPOINT is missing in AWS environment"
        )

    if not os.getenv("RDS_SECRET_ARN"):
        raise RuntimeError(
            "RDS_SECRET_ARN is missing in AWS environment"
        )

    from .aws_secrets import get_rds_database_url

    DATABASE_URL = get_rds_database_url()

else:
    DATABASE_URL = os.getenv(
        "DATABASE_URL",
        "sqlite:///./tickets.db"
    )


# Use AWS Secrets Manager when RDS configuration is supplied
if os.getenv("RDS_SECRET_ARN") and os.getenv("RDS_ENDPOINT"):
    from .aws_secrets import get_rds_database_url

    DATABASE_URL = get_rds_database_url()

connect_args = {}

if str(DATABASE_URL).startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()
