#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100002 (INTERNAL PORT SWEEPING) ---

# Pinalitan ang IP para tumugma sa target lab environment mo
TARGET="172.16.16.100" 

echo "Starting aggressive Nmap scan on $TARGET..."

# EXPLANATION PARA SA DEFENSE:
# -p 1-65535: Scans all 65k TCP ports para ma-trigger ang UFW block threshold.
# -T4: Aggressive timing (mabilis ang pagbato ng packets).
# -A: OS detection at script scanning para mas maingay sa network logs.
nmap -p 1-65535 -T4 -Pn -A -v $TARGET

echo "Scan complete. Check Wazuh alerts (OpenSearch dashboard) for scanning activities."
