#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100003 (DATA EXFILTRATION) ---
# Rule 3 (RA 10173): Metadata-only logging. No actual payloads or user data.
# Rule 4 (Heuristic Validity): Generates multiple telemetry events to trigger
#        frequency="3" timeframe="120" threshold in local_rules.xml (Rule 100003).

TARGET="192.168.202.144"
SRC_IP="$(hostname -I | awk '{print $1}')"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "[*] Simulating Data Exfiltration telemetry to $TARGET..."

# Step 1: Generate 4 metadata-only syslog events (exceeds frequency="3" threshold)
for i in {1..4}; do
    BYTES_OUT=$((RANDOM % 50000 + 10000))
    logger "capstone_exfil_event: src_ip=$SRC_IP dst_ip=$TARGET bytes_transferred=$BYTES_OUT protocol=TCP dst_port=443 timestamp=$TIMESTAMP event_id=$i"
    echo "[+] Event $i sent: src=$SRC_IP dst=$TARGET bytes=$BYTES_OUT"
    sleep 2
done

echo "[*] Data exfiltration simulation complete! Check Wazuh SIEM for Rule 100003."