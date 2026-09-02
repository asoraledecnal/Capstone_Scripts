#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100005 (LIVE CRYPTOJACKING DETONATION) ---
# Rule 3 (RA 10173): Metadata-only logging. No actual payloads or user data.
# Rule 4 (Heuristic Validity): Generates multiple telemetry events to trigger
#        frequency="3" timeframe="60" threshold in local_rules.xml (Rule 100005).

SRC_IP="$(hostname -I | awk '{print $1}')"
C2_SERVER="192.168.202.144"

echo "[*] Simulating Sustained Resource Exhaustion (Cryptojacking)..."
echo "[*] Spiking CPU to 100% and generating telemetry events..."

# Step 1: Spike CPU utilization in the background (30 seconds)
stress-ng --cpu 2 --timeout 30s -q &
STRESS_PID=$!

# Step 2: Generate 4 metadata-only syslog events (exceeds frequency="3" threshold)
for i in {1..4}; do
    CPU_USAGE=$((95 + RANDOM % 5))
    logger "capstone_cryptojack_event: src_ip=$SRC_IP process_name=xmrig pid=$STRESS_PID cpu_percent=$CPU_USAGE dst_ip=$C2_SERVER dst_port=4444 timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ) event_id=$i"
    echo "[+] Event $i sent: process=xmrig pid=$STRESS_PID cpu=${CPU_USAGE}%"
    sleep 3
done

# Step 3: Attempt to contact C2 server (connection should be killed by agent response)
echo "[*] Attempting to contact C2 server ($C2_SERVER)..."
nc -vw 5 $C2_SERVER 4444 2>&1 || echo "[!] Connection failed or was blocked."

echo "[*] Attack simulation complete! Check htop and Wazuh SIEM for Rule 100005."