# Laketec Ansible Automation Demo Guide
## AOS-CX Network Automation with Ansible

---

## 📋 Demo Overview

This demo showcases how Ansible can automate network configuration across HPE Aruba AOS-CX switches. We'll demonstrate:

1. **Infrastructure as Code** - Network configs defined in YAML files
2. **Idempotency** - Running playbooks multiple times safely  
3. **Consistency** - Same config applied across all devices
4. **Speed** - Configure 5 switches in seconds vs 30+ minutes manually
5. **Auditability** - Version control your network configurations

---

## 🖥️ Lab Environment

| Device   | IP Address    | Role         |
|----------|---------------|--------------|
| spine1   | 172.20.20.5   | Spine Switch |
| spine2   | 172.20.20.6   | Spine Switch |
| leaf1    | 172.20.20.3   | Leaf Switch  |
| leaf2    | 172.20.20.4   | Leaf Switch  |
| leaf3    | 172.20.20.2   | Leaf Switch  |
| host1    | 172.20.20.8   | Ansible Control Node |

---

## 🚀 Step-by-Step Demo

### Pre-Demo Setup



---

### STEP 1: Test Connectivity (2 min)
### STEP 0: Enable REST API (Run First!)

**What it shows:** REST API must be enabled before other playbooks work

```bash
ansible-playbook playbooks/00_setup_rest_api.yml
```

**Talking Points:**
- This step uses SSH/CLI connection (not REST API) to enable the REST API
- Must be run ONCE before any other playbooks
- Enables HTTPS REST interface with read-write access
- Verifies API is responding before proceeding
- Only needs to run once per switch (idempotent - safe to re-run)

---


**What it shows:** Ansible can reach all devices via REST API



**Talking Points:**
- Ansible connects to AOS-CX via REST API (not SSH/CLI)
- Parallel execution - all 5 switches tested simultaneously
- No agents required on switches

---

### STEP 2: Gather Facts (2 min)

**What it shows:** Ansible can collect device information programmatically



**Talking Points:**
- Automatically discovers device details (hostname, version, model)
- Could export to CMDB, documentation, or compliance reports
- Foundation for dynamic inventory management

---

### STEP 3: Configure VLANs (3 min)

**What it shows:** Bulk configuration with loops and variables



**Talking Points:**
- VLANs defined once in group_vars, applied to all switches
- Uses loops to create multiple VLANs efficiently
- Idempotent - run again and no changes occur
- Demo idempotency by running it twice!

**Show the VLAN definitions:**


---

### STEP 4: Configure SNMPv3 (3 min)

**What it shows:** Security-focused configuration management



**Talking Points:**
- Credentials stored in variables (could use Ansible Vault for encryption)
- SHA authentication + AES privacy - secure monitoring
- Consistent security posture across all devices
- Compliance-ready configuration

---

### STEP 5: Configure Syslog (2 min)

**What it shows:** Centralized logging configuration



**Talking Points:**
- All switches now send logs to central server
- Critical for security monitoring and troubleshooting
- Change the server IP in one place, update everywhere

---

### STEP 6: Configure NetFlow/IPFIX (2 min)

**What it shows:** Traffic visibility and analytics



**Talking Points:**
- IPFIX export enabled for traffic analysis
- Feed into tools like SolarWinds, PRTG, Kentik, etc.
- Network visibility at scale

---

### STEP 7: Backup Configurations (2 min)

**What it shows:** Automated configuration backup with timestamps

total 464044
drwxrwxr-x 2 jason jason      4096 Jun 20 16:13 .
drwxrwxrwx 9 root  root       4096 Dec  1 22:51 ..
-rw-rw-r-- 1 jason jason   1410927 Apr 18  2025 lingo.0.2.zip
-rw-rw-r-- 1 jason jason   1584629 Apr 29  2025 lingo.0.4.zip
-rw-rw-r-- 1 jason jason 127297324 May 20  2025 lingo.0.6.0.zip
-rw-rw-r-- 1 jason jason 215253845 Jun 20 12:25 lingo.0.6.1.zip
-rw-rw-r-- 1 jason jason 129604675 Jun 20 16:11 lingo_backup_20250620_161058.tar.gz
-rw-rw-r-- 1 jason jason       598 Apr 29  2025 translator.0.1.zip

**Talking Points:**
- Timestamped backups for disaster recovery
- Could integrate with Git for version control
- Schedule with cron for regular backups
- Compare configs over time

---

### BONUS: Run Full Demo (5 min)

**What it shows:** Complete automation workflow



---

### BONUS: Rollback/Cleanup (2 min)

**What it shows:** Easy rollback capability



**Talking Points:**
- Same tool that creates can also remove
- state: present vs state: absent
- Safe rollback procedures

---

## 💡 Key Messages for Engineers

### Why Ansible for Network Automation?

1. **Agentless** - No software to install on network devices
2. **Human-Readable** - YAML playbooks anyone can understand
3. **Idempotent** - Safe to run multiple times
4. **Extensible** - 1000s of modules for different vendors
5. **Free & Open Source** - Community support, enterprise options available

### Business Value

| Manual Process | With Ansible |
|----------------|--------------|
| 30+ min per device | Seconds for all devices |
| Human error risk | Consistent every time |
| No audit trail | Full version control |
| One device at a time | Parallel execution |
| Tribal knowledge | Documented as code |

### Real-World Use Cases

- **Day 0**: Initial switch provisioning
- **Day 1**: VLAN/interface configuration
- **Day 2**: Monitoring setup (SNMP, Syslog, NetFlow)
- **Ongoing**: Compliance auditing, backup, remediation
- **Emergency**: Rapid security policy deployment

---

## 📁 Directory Structure



---

## 🔧 Quick Reference Commands



---

## 📞 Questions?

**Laketec** - Your Technology Partner

---

*Demo created with Ansible + AOS-CX Collection*
