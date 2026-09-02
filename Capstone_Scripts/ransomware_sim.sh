#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100001 (RANSOMWARE BEHAVIOR) ---

# Folder na binabantayan ng Wazuh FIM (File Integrity Monitoring)
TARGET_DIR="/tmp/important_files"

echo "Step 1: Creating dummy target directory at $TARGET_DIR..."
mkdir -p $TARGET_DIR

echo "Step 2: Generating legitimate dummy files..."
# Gagawa ng 10 normal na text files para may ma-hostage ang ransomware
for i in {1..10}; do
    echo "Confidential Data $i" > "$TARGET_DIR/document_$i.txt"
done

# Bigyan ng 2 seconds ang Wazuh para ma-register na may bagong normal files
sleep 2 

echo "Step 3: Simulating Ransomware Encryption Phase..."
# Hahanapin lahat ng .txt files at mabilisang papalitan ang extension
for file in $TARGET_DIR/*.txt; do
    # Papalitan ang .txt at gagawing .encrypted para i-trigger ang <match>.encrypted</match> sa rule mo
    mv "$file" "${file}.encrypted"
    echo "Encrypted: $file -> ${file}.encrypted"
done

echo "Attack simulation complete. Check Wazuh logs for syscheck alerts!"
