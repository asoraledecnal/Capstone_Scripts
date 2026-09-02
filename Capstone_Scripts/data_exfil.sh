#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100003 (DATA EXFILTRATION) ---

TARGET="192.168.202.144"
FILE="/tmp/secret_data.tar.gz"

echo "Simulating Data Exfil to $TARGET..."

# 1. Gumawa ng 50MB dummy file sa background
dd if=/dev/zero of=$FILE bs=1M count=50 status=none

# 2. I-trigger ang Wazuh agent gamit ang eksaktong keyword
logger "large outbound transfer anomaly: 50MB payload sent to external IP $TARGET"

# 3. Burahin agad ang file para hindi maubos ang 1.2GB storage ng VM mo
rm -f $FILE

echo "Data exfiltration simulation complete! Check Wazuh SIEM for Rule 100003."