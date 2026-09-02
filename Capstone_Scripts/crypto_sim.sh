#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100005 (LIVE CRYPTOJACKING DETONATION) ---

echo "Simulating Sustained Resource Exhaustion (Cryptojacking)..."
echo "Spiking CPU to 100% and opening outbound netcat connection..."

# 1. Pataasin ang CPU utilization (Tatakbo ng 30 seconds sa background)
stress-ng --cpu 2 --timeout 30s -q &

# 2. I-trigger ang Wazuh SIEM rule para maputol agad ng Sophos ang connection
logger "resource exhaustion cpu high: unknown process 'xmrig' utilizing 99% CPU with active socket to 192.168.202.144"

# 3. Subukang kumonekta kay Kali (Dito makikita ng panel na biglang ma-ta-timeout ang connection dahil sa firewall)
echo "Attempting to contact C2 server (192.168.202.144)..."
nc -vw 5 192.168.202.144 4444

echo "Attack simulation complete! Check htop and Wazuh SIEM for Rule 100005."