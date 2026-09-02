#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100006 (PASS-THE-HASH / LATERAL MOVEMENT) ---
# Rule 3 (RA 10173): Metadata-only logging. No actual payloads or user data.
# Rule 4 (Heuristic Validity): Generates multiple telemetry events to trigger
#        frequency="5" timeframe="120" threshold in local_rules.xml (Rule 100006).

SRC_IP="$(hostname -I | awk '{print $1}')"
DEST_SERVERS=("10.0.0.1" "10.0.0.2" "10.0.0.3" "10.0.0.4" "10.0.0.5" "10.0.0.6")

echo "[*] Simulating Anomalous Lateral Authentication (Pass-the-Hash)..."
echo "[*] Faking rapid logins to multiple regional servers..."

# Generate 6 metadata-only syslog events (exceeds frequency="5" threshold)
for i in {1..6}; do
    DST="${DEST_SERVERS[$((i-1))]}"
    logger "capstone_lateralauth_event: src_ip=$SRC_IP dst_ip=$DST auth_method=NTLM user=svc_admin status=success timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ) event_id=$i"
    echo "[+] Event $i sent: src=$SRC_IP dst=$DST method=NTLM user=svc_admin"
    sleep 2
done

echo "[*] Attack simulation complete! Check Wazuh SIEM for Rule 100006."