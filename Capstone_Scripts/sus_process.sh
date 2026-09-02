#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100004 (SUSPICIOUS PROCESS SPAWNING) ---
# Rule 3 (RA 10173): Metadata-only logging. No actual payloads or user data.
# Rule 4 (Heuristic Validity): Generates multiple telemetry events to trigger
#        frequency="2" timeframe="30" threshold in local_rules.xml (Rule 100004).

SRC_IP="$(hostname -I | awk '{print $1}')"

echo "[*] Simulating Living-off-the-Land (LotL) Attack..."
echo "[*] Spawning fake PowerShell process metadata via syslog..."

# Generate 3 metadata-only syslog events (exceeds frequency="2" threshold)
for i in {1..3}; do
    FAKE_PID=$((RANDOM % 9000 + 1000))
    logger "capstone_susproc_event: src_ip=$SRC_IP parent_process=WINWORD.EXE child_process=powershell.exe child_pid=$FAKE_PID execution_policy=Bypass timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ) event_id=$i"
    echo "[+] Event $i sent: parent=WINWORD.EXE child=powershell.exe pid=$FAKE_PID"
    sleep 3
done

echo "[*] Attack simulation complete! Check Wazuh SIEM for Rule 100004."