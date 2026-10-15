
#!/bin/bash
set -euo pipefail

dnf install -y \
    python3.11 \
    python3.11-pip \
    unzip \
    awscli-2

# Verify prerequisites
python3.11 --version
python3.11 -m pip --version
aws --version
unzip -v

echo "Application Support runtime prepared."
