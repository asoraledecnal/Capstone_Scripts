#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 100001 (RANSOMWARE BEHAVIOR) ---
# Rule 3 (RA 10173): Metadata-only logging. No actual payloads or user data.
#        Generated files contain ONLY placeholder markers, not simulated user content.
# Rule 4 (Heuristic Validity): Mass file rename (.txt -> .encrypted) triggers
#        Wazuh FIM (syscheck) which fires Rule 100001 via <match>.encrypted</match>.

TARGET_DIR="/tmp/important_files"
FILE_COUNT=10

echo "[*] Step 1: Creating dummy target directory at $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

echo "[*] Step 2: Generating placeholder files (metadata-only, no user data)..."
for i in $(seq 1 $FILE_COUNT); do
    # RA 10173 Compliant: File content is a non-sensitive placeholder marker only.
    echo "CAPSTONE_PLACEHOLDER_FILE_$i" > "$TARGET_DIR/document_$i.txt"
done
echo "[+] $FILE_COUNT placeholder files created."

# Allow Wazuh FIM 2 seconds to register the baseline files
sleep 2

echo "[*] Step 3: Simulating Ransomware Encryption Phase..."
ENCRYPTED_COUNT=0
for file in "$TARGET_DIR"/*.txt; do
    mv "$file" "${file}.encrypted"
    ENCRYPTED_COUNT=$((ENCRYPTED_COUNT + 1))
    # Metadata-only log: file path and timestamp, no file contents.
    echo "[+] Encrypted ($ENCRYPTED_COUNT/$FILE_COUNT): $(basename "$file") -> $(basename "${file}.encrypted") at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
done

echo "[*] Attack simulation complete. $ENCRYPTED_COUNT files encrypted."
echo "[*] Check Wazuh logs for syscheck alerts triggering Rule 100001."
