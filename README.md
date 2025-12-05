# Laketec Ansible Network Automation Lab

A turnkey containerlab environment for demonstrating Ansible automation with HPE Aruba AOS-CX virtual switches in a spine-leaf topology.

## Quick Start (TL;DR)

```bash
# After completing Windows/WSL setup below, run these commands in WSL:
git clone https://github.com/laketec/ansible-lab.git
cd ansible-lab
./scripts/setup-environment.sh
sudo clab deploy -t lab01.clab.yml
ansible-playbook playbooks/00_setup_rest_api.yml
ansible-playbook playbooks/full_demo.yml
```

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Windows Setup with WSL2](#windows-setup-with-wsl2)
3. [Docker Installation](#docker-installation)
4. [Containerlab Installation](#containerlab-installation)
5. [Azure Container Registry - AOS-CX Image](#azure-container-registry---aos-cx-image)
6. [VS Code Setup](#vs-code-setup)
7. [Lab Deployment](#lab-deployment)
8. [Running the Demo](#running-the-demo)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Hardware Requirements
- **CPU**: Hardware virtualization enabled in BIOS (Intel VT-x or AMD-V/SVM)
- **RAM**: 16GB minimum (32GB recommended for full lab)
- **Disk**: 50GB free space
- **OS**: Windows 10 (version 2004+) or Windows 11

### Software Requirements (installed during setup)
- WSL2 with Ubuntu
- Docker
- Containerlab
- Ansible 2.10+
- Python 3.8+
- VS Code with extensions

---

## Windows Setup with WSL2

### Step 1: Enable Hardware Virtualization

1. Reboot your computer and enter BIOS/UEFI settings (usually F2, F10, F12, or Del during boot)
2. Find virtualization settings:
   - **Intel**: Enable "Intel VT-x" or "Intel Virtualization Technology"
   - **AMD**: Enable "SVM Mode" or "AMD-V"
3. Save and exit BIOS

### Step 2: Install WSL2

#### Windows 11 or Windows 10 (version 2004+)

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

Restart your computer when prompted.

#### Windows 10 (older versions)

Open **PowerShell as Administrator** and run:

```powershell
# Enable WSL feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Restart your computer, then:

1. Download the [WSL2 Linux kernel update package](https://aka.ms/wsl2kernel)
2. Run the installer
3. Set WSL2 as default:

```powershell
wsl --set-default-version 2
```

### Step 3: Install WSL-Containerlab Distribution (Recommended)

The Containerlab team provides a pre-configured WSL distribution with everything you need.

1. Verify WSL version (need 2.4.4 or newer):

```powershell
wsl --version
```

2. Download the latest `.wsl` file from: https://github.com/srl-labs/wsl-containerlab/releases/latest

3. Install by double-clicking the `.wsl` file, or run:

```powershell
wsl --install --from-file C:\Users\YourName\Downloads\clab.wsl
```

4. Follow the setup wizard to:
   - Select your preferred shell (bash/zsh/fish)
   - Generate SSH keys for passwordless access
   - Complete initial configuration

### Alternative: Manual Ubuntu Installation

If you prefer a manual setup:

```powershell
wsl --install -d Ubuntu-22.04
```

Then launch Ubuntu from the Start menu and create your user account.

---

## Docker Installation

### If Using WSL-Containerlab Distribution

Docker is pre-installed. Verify with:

```bash
sudo docker version
```

### If Using Manual Ubuntu Installation

**Important**: Do NOT use Docker Desktop's WSL integration. Install Docker directly in WSL.

```bash
# Update packages
sudo apt update && sudo apt -y install curl

# Install Docker and Containerlab together
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"

# Verify installation
docker version
```

### Docker Post-Installation

Add your user to the docker group (avoids needing sudo):

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## Containerlab Installation

### If Using WSL-Containerlab Distribution

Containerlab is pre-installed. Verify with:

```bash
clab version
```

### If Using Manual Setup

```bash
# Install containerlab
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"

# Verify installation
clab version
```

---

## Azure Container Registry - AOS-CX Image

The AOS-CX virtual switch images must be pulled from Azure Container Registry.

### Step 1: Install Azure CLI

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Step 2: Login to Azure

```bash
az login
```

### Step 3: OPTIONAL STEP Login to Azure Container Registry (If you have an Azure Login but not Required!)

```bash
# Login to ACR
az acr login --name laketec

# Or use docker login directly
docker login laketec.azurecr.io
```

### Step 4: Pull the AOS-CX Image

```bash
# Pull from ACR
docker pull laketec.azurecr.io/aoscx:10.15.1005

# Tag for local use (matches lab topology file)
docker tag laketec.azurecr.io/aoscx:10.15.1005 aoscx:10.15.1005
```

### Step 5: Pull the Ubuntu SSH Image

```bash
docker pull laketec.azurecr.io/ubuntu-ssh:24.04
docker tag laketec.azurecr.io/ubuntu-ssh:24.04 ubuntu-ssh:24.04
```

### Uploading Images to Azure Container Registry (ACR, Azure Admins Only)

If you need to upload the an image to your ACR:

```bash
# Create ACR (if not exists)
az acr create --resource-group <your-rg> --name <your-acr-name> --sku Basic

# Enable admin user (for docker login)
az acr update --name <your-acr-name> --admin-enabled true

# Get ACR credentials
az acr credential show --name <your-acr-name>

# Login to ACR
az acr login --name <your-acr-name>

# Tag and push a new image
docker tag <containername> laketec.azurecr.io/<containername>
docker push laketec.azurecr.io/<containername>
```

---

## VS Code Setup

The Containerlab extension for VS Code provides an integrated graphical interface for managing container-based network labs directly within your editor.

  Key Features

  - Topology Visualization: View your network topology as an interactive graph diagram, making it easier to understand complex multi-node designs
  - Lab Management: Deploy, destroy, and inspect labs without leaving VS Code
  - Node Interaction: Connect to lab nodes (routers, switches, hosts) via SSH directly from the editor
  - YAML Support: Syntax highlighting and validation for .clab.yml topology files
  - Status Monitoring: See which labs are running and the state of individual nodes

  Why It's Important

  1. Streamlined Workflow: Eliminates context-switching between terminal and editor - you can edit configs, deploy labs, and troubleshoot all in one place
  2. Visual Understanding: Network topologies are inherently visual. Seeing a graph of spine/leaf connections (like your lab with 2 spines, 3 leaves, and 2 hosts) is
  far more intuitive than reading YAML
  3. Faster Troubleshooting: One-click SSH access to nodes speeds up debugging and testing
  4. Lower Barrier to Entry: Makes containerlab more accessible to those less comfortable with CLI-only workflows
  5. Ansible Integration: Pairs well with the Ansible extension - you can visualize your lab topology while developing and testing playbooks against it

  For your demo environment with Aruba AOS-CX switches and Ubuntu hosts, this extension would let participants visually see the network topology and quickly connect
  to any device for hands-on learning.

### Step 1: Install VS Code on Windows

Download and install from: https://code.visualstudio.com/

### Step 2: Install Required Extensions

Open VS Code and install these extensions (Ctrl+Shift+X):

1. **WSL** (ms-vscode-remote.remote-wsl) - Required for WSL integration
2. **Containerlab** (srl-labs.containerlab) - Lab management and visualization
3. **Ansible** (redhat.ansible) - Ansible syntax highlighting and IntelliSense
4. **YAML** (redhat.vscode-yaml) - YAML language support

Or install via command line:

```powershell
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension srl-labs.containerlab
code --install-extension redhat.ansible
code --install-extension redhat.vscode-yaml
```

### Step 3: Connect VS Code to WSL

1. Open VS Code
2. Press `F1` or `Ctrl+Shift+P`
3. Type "WSL: Connect to WSL" and select it
4. VS Code will reload connected to your WSL environment

### Step 4: Open the Lab Project

In VS Code (connected to WSL):

```bash
# Clone the repository
cd ~
git clone https://github.com/laketec/ansible-lab.git
cd ansible-lab
code .
```

### Containerlab Extension Features

Once connected to WSL with the Containerlab extension:

- **Explorer Panel**: View discovered topologies and running labs
- **TopoViewer**: Graphical topology visualization (`Ctrl+Alt+G`)
- **Quick Deploy**: Deploy labs directly from editor (`Ctrl+Alt+D`)
- **Quick Destroy**: Stop labs (`Ctrl+Alt+K`)
- **SSH Access**: Click on nodes to open terminal connections
- **Draw.io Diagrams**: Right-click labs to generate network diagrams

**Keyboard Shortcuts**:
| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+D` | Deploy topology |
| `Ctrl+Alt+R` | Redeploy topology |
| `Ctrl+Alt+K` | Destroy topology |
| `Ctrl+Alt+G` | Open graph view |

---

## Lab Deployment

### Step 1: Clone the Repository

```bash
cd ~
git clone https://github.com/laketec/ansible-lab.git
cd ansible-lab
```

### Step 2: Run the Setup Script

```bash
chmod +x scripts/setup-environment.sh
./scripts/setup-environment.sh
```

This script will:
- Install Ansible and required Python packages
- Install the HPE Aruba AOS-CX Ansible collection
- Verify Docker and Containerlab are working
- Check that required container images are available

### Step 3: Deploy the Lab

```bash
sudo clab deploy -t lab01.clab.yml
```

Expected output:
```
+---+-----------------+--------------+-------------------+-------+---------+----------------+
| # |      Name       | Container ID |       Image       | Kind  |  State  |  IPv4 Address  |
+---+-----------------+--------------+-------------------+-------+---------+----------------+
| 1 | clab-lab01-host1| xxxxxxxxxxxx | ubuntu-ssh:24.04  | linux | running | 172.20.20.x/24 |
| 2 | clab-lab01-host2| xxxxxxxxxxxx | ubuntu-ssh:24.04  | linux | running | 172.20.20.x/24 |
| 3 | clab-lab01-leaf1| xxxxxxxxxxxx | aoscx:10.15.1005  | aoscx | running | 172.20.20.3/24 |
| 4 | clab-lab01-leaf2| xxxxxxxxxxxx | aoscx:10.15.1005  | aoscx | running | 172.20.20.4/24 |
| 5 | clab-lab01-leaf3| xxxxxxxxxxxx | aoscx:10.15.1005  | aoscx | running | 172.20.20.2/24 |
| 6 | clab-lab01-spine1| xxxxxxxxxxxx | aoscx:10.15.1005 | aoscx | running | 172.20.20.5/24 |
| 7 | clab-lab01-spine2| xxxxxxxxxxxx | aoscx:10.15.1005 | aoscx | running | 172.20.20.6/24 |
+---+-----------------+--------------+-------------------+-------+---------+----------------+
```

### Step 4: Wait for Switches to Boot

AOS-CX virtual switches take 2-3 minutes to fully boot. Check status:

```bash
# Check if switches are responding
ansible aoscx_switches -m ping
```

---

## Running the Demo

### Network Topology

```
                    +----------+     +----------+
                    |  spine1  |     |  spine2  |
                    |172.20.20.5|    |172.20.20.6|
                    +----+-----+     +----+-----+
                         |                |
          +--------------+----------------+--------------+
          |              |                |              |
     +----+-----+   +----+-----+    +----+-----+
     |  leaf1   |   |  leaf2   |    |  leaf3   |
     |172.20.20.3|  |172.20.20.4|   |172.20.20.2|
     +----+-----+   +----+-----+    +----------+
          |              |
     +----+-----+   +----+-----+
     |  host1   |   |  host2   |
     +----------+   +----------+
```

### Step 1: Enable REST API (Required First)

```bash
ansible-playbook playbooks/00_setup_rest_api.yml
```

### Step 2: Test Connectivity

```bash
ansible-playbook playbooks/01_test_connectivity.yml
```

### Step 3: Run Full Demo

```bash
ansible-playbook playbooks/full_demo.yml
```

### Individual Playbooks

| Playbook | Description |
|----------|-------------|
| `00_setup_rest_api.yml` | Enable HTTPS REST API on all switches |
| `01_test_connectivity.yml` | Test SSH and REST API connectivity |
| `02_gather_facts.yml` | Collect device info (version, serial, etc.) |
| `03_configure_vlans.yml` | Create demo VLANs (100-400) |
| `04_configure_snmpv3.yml` | Configure SNMPv3 with SHA/AES |
| `05_configure_syslog.yml` | Enable centralized syslog |
| `06_configure_ntp.yml` | Configure NTP servers |
| `07_backup_configs.yml` | Backup running configurations |
| `08_cleanup_vlans.yml` | Remove demo VLANs |
| `09_configure_dns.yml` | Configure DNS settings |
| `full_demo.yml` | Run all configuration steps |
| `reset_lab.yml` | Remove all demo configurations |

### Target Specific Devices

```bash
# Run on spine switches only
ansible-playbook playbooks/03_configure_vlans.yml --limit spines

# Run on a single device
ansible-playbook playbooks/02_gather_facts.yml --limit leaf1
```

---

## Lab Management

### View Running Labs

```bash
sudo clab inspect --all
```

### Stop the Lab

```bash
sudo clab destroy -t lab01.clab.yml
```

### SSH to a Switch

```bash
ssh admin@172.20.20.5  # spine1
# Password: admin
```

### View Lab Logs

```bash
docker logs clab-lab01-spine1
```

---

## Project Structure

```
ansible-lab/
├── README.md                    # This file
├── DEMO_GUIDE.md               # Presentation guide for demos
├── lab01.clab.yml              # Containerlab topology definition
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   └── hosts.yml               # Device inventory (5 switches)
├── group_vars/
│   └── aoscx_switches.yml      # Shared variables (VLANs, SNMP, etc.)
├── playbooks/
│   ├── 00_setup_rest_api.yml   # Enable REST API (run first!)
│   ├── 01_test_connectivity.yml
│   ├── 02_gather_facts.yml
│   ├── 03_configure_vlans.yml
│   ├── 04_configure_snmpv3.yml
│   ├── 05_configure_syslog.yml
│   ├── 06_configure_ntp.yml
│   ├── 07_backup_configs.yml
│   ├── 08_cleanup_vlans.yml
│   ├── 09_configure_dns.yml
│   ├── full_demo.yml
│   └── reset_lab.yml
├── backups/                    # Configuration backups
└── scripts/
    └── setup-environment.sh    # Automated environment setup
```

---

## Configuration Variables

All configuration is centralized in `group_vars/aoscx_switches.yml`:

### VLANs
```yaml
demo_vlans:
  - id: 100
    name: LAKETEC_MGMT
  - id: 200
    name: LAKETEC_DATA
  - id: 300
    name: LAKETEC_VOICE
  - id: 400
    name: LAKETEC_IOT
```

### Monitoring
```yaml
snmpv3_user: laketec_monitor
syslog_server: 10.0.0.1
ntp_servers:
  - 10.0.0.1
  - pool.ntp.org
```

---

## Troubleshooting

### WSL Issues

**WSL not starting:**
```powershell
# Check WSL status
wsl --status

# Update WSL
wsl --update

# Restart WSL
wsl --shutdown
```

**Cannot enable virtualization:**
- Verify hardware virtualization is enabled in BIOS
- Disable Hyper-V conflicts: `bcdedit /set hypervisorlaunchtype off`

### Docker Issues

**Docker not running:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

**Permission denied:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Docker Desktop conflicts:**
- Disable Docker Desktop WSL integration in Docker Desktop settings
- Uninstall Docker Desktop if only using WSL

### Containerlab Issues

**Lab won't deploy:**
```bash
# Check Docker is running
docker ps

# Check images are available
docker images | grep aoscx

# Deploy with debug output
sudo clab deploy -t lab01.clab.yml --debug
```

**Switches not responding:**
```bash
# Wait longer - AOS-CX takes 2-3 minutes to boot
sleep 180

# Check container status
docker ps -a

# View switch logs
docker logs clab-lab01-spine1
```

### Ansible Issues

**Connection timeouts:**
```bash
# Increase timeout in ansible.cfg
[persistent_connection]
connect_timeout = 120
command_timeout = 120
```

**REST API errors:**
```bash
# Ensure REST API is enabled first
ansible-playbook playbooks/00_setup_rest_api.yml
```

**Collection not found:**
```bash
ansible-galaxy collection install arubanetworks.aoscx --force
```

### ACR Issues

**Authentication failed:**
```bash
# Re-login to Azure
az login

# Re-login to ACR
az acr login --name <your-acr-name>
```

**Image not found:**
```bash
# List available images in ACR
az acr repository list --name <your-acr-name>

# List tags for an image
az acr repository show-tags --name <your-acr-name> --repository aoscx
```

---

## Security Notes

- Default credentials (`admin/admin`) are used for this demo environment
- In production, use Ansible Vault to encrypt sensitive variables:

```bash
ansible-vault encrypt group_vars/aoscx_switches.yml
ansible-playbook playbooks/full_demo.yml --ask-vault-pass
```

---

## Key Concepts Demonstrated

- **Idempotency**: Playbooks can be run multiple times safely
- **Parallel Execution**: All 5 switches configured simultaneously
- **Infrastructure as Code**: All configurations version-controlled
- **Variable-Driven**: Change `group_vars` to modify all configurations
- **Automated Backups**: Timestamped configuration snapshots

---

## Resources

- [Containerlab Documentation](https://containerlab.dev/)
- [Containerlab Windows Guide](https://containerlab.dev/windows/)
- [VS Code Containerlab Extension](https://containerlab.dev/manual/vsc-extension/)
- [HPE Aruba AOS-CX Ansible Collection](https://galaxy.ansible.com/arubanetworks/aoscx)
- [Ansible Documentation](https://docs.ansible.com/)

---

## License

This project is provided as a demonstration environment.

## Author

Laketec - Network Automation Demo
