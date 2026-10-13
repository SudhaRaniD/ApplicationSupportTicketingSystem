
#!/bin/bash
set -euo pipefail

# Save startup logs
exec > >(tee /var/log/application-support-setup.log) 2>&1

# # Update packages
# dnf update -y

# # Install Python and pip
# dnf install -y python3 python3-pip

# # Create application directory
# mkdir -p /opt/application-support
# cd /opt/application-support

# # Create Python virtual environment
# python3 -m venv venv

# # Install FastAPI and Uvicorn
# /opt/application-support/venv/bin/pip install fastapi uvicorn

# # Create a temporary FastAPI application
# cat > main.py <<'PYTHON'
# from fastapi import FastAPI

# app = FastAPI(title="Application Support Ticketing System")

# @app.get("/")
# def home():
#     return {"message": "Application Support API is running"}

# @app.get("/health")
# def health():
#     return {"status": "healthy"}
# PYTHON

# # Create systemd service
# cat > /etc/systemd/system/application-support.service <<'SERVICE'
# [Unit]
# Description=Application Support FastAPI
# After=network-online.target
# Wants=network-online.target

# [Service]
# User=root
# WorkingDirectory=/opt/application-support
# ExecStart=/opt/application-support/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
# Restart=always
# RestartSec=5

# [Install]
# WantedBy=multi-user.target
# SERVICE

# # Start FastAPI
# systemctl daemon-reload
# systemctl enable application-support
# systemctl start application-support


#!/bin/bash
# set -euo pipefail

# exec > >(tee /var/log/application-support-setup.log) 2>&1

# dnf install -y python3 python3-pip

# APP_DIR="/opt/application-support"
# mkdir -p "$APP_DIR"

# # Application source code must be delivered
# # securely to APP_DIR before starting the service.

# if [ ! -f "$APP_DIR/ApplicationSupportBackEnd/main.py" ]; then
#     echo "Application source code not found."
#     exit 1
# fi

# cd "$APP_DIR"

# python3 -m venv venv
# ./venv/bin/pip install -r ApplicationSupportBackEnd/requirements.txt

# cat > /etc/systemd/system/application-support.service <<'SERVICE'
# [Unit]
# Description=Application Support Ticketing System
# After=network-online.target
# Wants=network-online.target

# [Service]
# WorkingDirectory=/opt/application-support
# ExecStart=/opt/application-support/venv/bin/uvicorn ApplicationSupportBackEnd.main:app --host 0.0.0.0 --port 8000
# Restart=always
# RestartSec=5

# [Install]
# WantedBy=multi-user.target
# SERVICE

# systemctl daemon-reload
# systemctl enable application-support
# systemctl start application-support



#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/application-support-setup.log) 2>&1

echo "Starting Application Support deployment..."

APP_DIR="/opt/application-support"
ZIP_FILE="/tmp/application-support-deployment.zip"

mkdir -p "$APP_DIR"

# Obtain the S3 bucket name from EC2 user data
S3_BUCKET="${s3_bucket_name}"

# Download the deployment package
aws s3 cp \
  "s3://$S3_BUCKET/application-support-deployment.zip"\
  "$ZIP_FILE"

# Extract the application
unzip -o "$ZIP_FILE" -d "$APP_DIR"

# Verify the backend exists
if [ ! -f "$APP_DIR/ApplicationSupportBackEnd/main.py" ]; then
    echo "ERROR: FastAPI application not found."
    exit 1
fi

echo "Application files downloaded successfully."
echo "Dependency installation and service startup are pending."
