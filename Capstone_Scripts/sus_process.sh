#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100004 (SUSPICIOUS PROCESS SPAWNING) ---

echo "Simulating Living-off-the-Land (LotL) Attack..."
echo "Spawning fake PowerShell process via MS Word..."

# --- COMMAND LINE BREAKDOWN ---
# 1. logger: Isang built-in Linux command na nagsusulat nang direkta sa system log (/var/log/syslog).
# 2. Plain text string: Nag-iiwan tayo ng malisyosong lagda na ginagaya ang isang Office app na nag-spawn ng PowerShell.
# 3. Bakit plain text?: Para madaling masalo ng string matcher ng Wazuh nang hindi nagkakamali sa JSON decoding.
logger "Suspicious process spawning anomaly: WINWORD.EXE executed powershell.exe -ExecutionPolicy Bypass -enc SQBFAFgA"

echo "Attack simulation complete! Check Wazuh SIEM for Rule 100004."