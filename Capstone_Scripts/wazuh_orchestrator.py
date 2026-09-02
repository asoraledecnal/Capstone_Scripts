PYTHON SCRIPT FOR sudo nano /var/ossec/active-response/bin/wazuh_orchestrator.py
#!/usr/bin/env python3
import sys
import json
import requests
import urllib3
import time
import random

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

LOG_FILE = "/var/ossec/logs/active-responses.log"

# --- CAPSTONE HEURISTIC WHITELISTS ---
WHITELISTED_IPS = ["127.0.0.1", "172.16.16.100", "172.16.16.20", "172.16.16.16", "192.168.202.1"]
WHITELISTED_SUBNETS = []

def is_whitelisted(ip):
    if not ip: return False
    if ip in WHITELISTED_IPS:
        return True
    for subnet in WHITELISTED_SUBNETS:
        if str(ip).startswith(subnet):
            return True
    return False

def log_message(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"wazuh_orchestrator: {msg}\n")

# --- SOPHOS REST API FUNCTIONS ---
def block_ip_on_sophos(ip):
    sophos_ip = "172.16.16.16"
    xml_payload = f'''<Request><Login><Username>admin</Username><Password>St0rage_Master_Key</Password></Login><Set><IPHost><Name>Blocked_{ip}</Name><IPFamily>IPv4</IPFamily><HostType>IP</HostType><IPAddress>{ip}</IPAddress><HostGroupList><HostGroup>Wazuh_Blacklist_Group</HostGroup></HostGroupList></IPHost></Set></Request>'''
    url = f"https://{sophos_ip}:4444/webconsole/APIController"
    
    max_retries = 5
    for attempt in range(max_retries):
        try:
            response = requests.post(url, data={'reqxml': xml_payload}, verify=False, timeout=10)
            if "Configuration applied successfully" in response.text:
                log_message(f"INFO: Successfully blocked IP {ip} on Sophos XG. (Attempt {attempt+1})")
                break
            else:
                log_message(f"WARNING: API Busy. Retrying block for IP {ip}... (Attempt {attempt+1})")
                time.sleep(random.uniform(1.0, 3.0))
        except Exception as e:
            log_message(f"ERROR: API request failed - {str(e)}. Retrying...")
            time.sleep(random.uniform(1.0, 3.0))

def unblock_ip_on_sophos(ip):
    sophos_ip = "172.16.16.16"
    xml_payload_step1 = f'''<Request><Login><Username>admin</Username><Password>St0rage_Master_Key</Password></Login><Set><IPHost><Name>Blocked_{ip}</Name><IPFamily>IPv4</IPFamily><HostType>IP</HostType><IPAddress>{ip}</IPAddress><HostGroupList></HostGroupList></IPHost></Set></Request>'''
    xml_payload_step2 = f'''<Request><Login><Username>admin</Username><Password>St0rage_Master_Key</Password></Login><Remove><IPHost><Name>Blocked_{ip}</Name></IPHost></Remove></Request>'''
    url = f"https://{sophos_ip}:4444/webconsole/APIController"
    
    max_retries = 5
    for attempt in range(max_retries):
        try:
            requests.post(url, data={'reqxml': xml_payload_step1}, verify=False, timeout=10)
            response = requests.post(url, data={'reqxml': xml_payload_step2}, verify=False, timeout=10)
            if "status=\"200\"" in response.text or "Configuration applied successfully" in response.text:
                log_message(f"INFO: Successfully REMOVED IP {ip} from Sophos XG (Timeout Expired - Attempt {attempt+1}).")
                break
            else:
                log_message(f"WARNING: API Busy. Retrying unblock for IP {ip}... (Attempt {attempt+1})")
                time.sleep(random.uniform(1.0, 3.0))
        except Exception as e:
            log_message(f"ERROR: Unblock API request failed - {str(e)}. Retrying...")
            time.sleep(random.uniform(1.0, 3.0))

# --- MAIN ORCHESTRATOR LOGIC ---
def main():
    input_data = sys.stdin.readline()

    if not input_data:
        sys.exit(1)

    try:
        data = json.loads(input_data)
    except json.JSONDecodeError:
        log_message("ERROR: Invalid JSON payload received.")
        sys.exit(1)

    command = data.get("command")
    alert_payload = data.get("parameters", {}).get("alert", {})
    rule_id = str(alert_payload.get("rule", {}).get("id"))

    # Target IP Extraction
    target_ip = alert_payload.get("data", {}).get("srcip") or alert_payload.get("data", {}).get("destip")
    if not target_ip:
        target_ip = alert_payload.get("srcip")
    if not target_ip:
        target_ip = alert_payload.get("agent", {}).get("ip")

    if not target_ip:
        print(json.dumps(data))
        sys.exit(1)

    # --- COMMAND EXECUTION ---
    if command == "add":
        if is_whitelisted(target_ip):
            log_message(f"DEBUG: IP {target_ip} is Whitelisted. Ignoring Alert from Rule {rule_id}.")
        else:
            # 1. SSH Brute Force
            if rule_id == "5712":
                log_message(f"DEBUG: Rule {rule_id} (SSH) triggered. Blocking {target_ip}.")
                block_ip_on_sophos(target_ip)

            # 2. Ransomware Behavior
            elif rule_id == "100001":
                process_name = alert_payload.get("data", {}).get("process_name", "")
                if process_name not in ["explorer.exe", "TiWorker.exe", "msiexec.exe"]:
                    log_message(f"DEBUG: Rule 100001 (Ransomware) triggered. Isolating {target_ip}.")
                    block_ip_on_sophos(target_ip)

            # 3. Data Exfiltration
            elif rule_id == "100003":
                log_message(f"DEBUG: Rule 100003 (Exfiltration) triggered. Blocking {target_ip}.")
                block_ip_on_sophos(target_ip)

            # 4. Cryptojacking / Resource Exhaustion
            elif rule_id == "100005":
                process_name = alert_payload.get("data", {}).get("process_name", "")
                if process_name not in ["chrome.exe", "firefox.exe", "vmware-vmx.exe", "msedge.exe"]:
                    log_message(f"DEBUG: Rule 100005 (Cryptojacking) triggered. Blocking {target_ip}.")
                    block_ip_on_sophos(target_ip)

            # 5. Internal Port Sweeping
            elif rule_id == "100002":
                log_message(f"DEBUG: Rule 100002 (Port Sweeping) triggered. Blocking {target_ip}.")
                block_ip_on_sophos(target_ip)

            # 6. Suspicious Process Spawning (Living off the Land)
            elif rule_id == "100004":
                log_message(f"DEBUG: Rule 100004 (LotL-PowerShell) triggered. Blocking {target_ip}.")
                block_ip_on_sophos(target_ip)

            # 7. Impossible Travel / Pass-the-Hash
            elif rule_id == "100006":
                log_message(f"DEBUG: Rule 100006 (Pass-the-Hash) triggered. Blocking {target_ip}.")
                block_ip_on_sophos(target_ip)

    elif command == "delete":
        log_message(f"INFO: Timeout reached. Sending UNBLOCK payload to Sophos XG for IP {target_ip}...")
        unblock_ip_on_sophos(target_ip)

    print(json.dumps(data))
    sys.stdout.flush()

if __name__ == "__main__":
    main()