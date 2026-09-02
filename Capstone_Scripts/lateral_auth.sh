#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100006 (PASS-THE-HASH / LATERAL MOVEMENT) ---

echo "Simulating Anomalous Lateral Authentication (Pass-the-Hash)..."
echo "Faking rapid logins to multiple regional servers..."

# --- COMMAND LINE BREAKDOWN ---
# 1. logger: Magpapadala ulit tayo ng fake syslog entry.
# 2. String Match: Hahanapin ng Wazuh ang salitang "authentication anomaly lateral movement".
logger "authentication anomaly lateral movement: Standard user account authenticated to 5 critical regional proxy nodes within 120 seconds."

echo "Attack simulation complete! Check Wazuh SIEM for Rule 100006."