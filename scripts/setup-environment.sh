#!/bin/bash
# =============================================================================
# Laketec Ansible Lab - Environment Setup Script
# =============================================================================
# This script sets up the complete environment for the Ansible demo lab.
# Run this script after WSL/Docker/Containerlab are installed.
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==============================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root (not recommended)
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root is not recommended. Some operations may fail."
        print_info "Consider running as a regular user with sudo privileges."
    fi
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    local errors=0

    # Check Docker
    print_info "Checking Docker..."
    if command -v docker &> /dev/null; then
        if docker ps &> /dev/null || sudo docker ps &> /dev/null; then
            print_success "Docker is installed and running"
            docker --version
        else
            print_error "Docker is installed but not running"
            print_info "Try: sudo systemctl start docker"
            errors=$((errors + 1))
        fi
    else
        print_error "Docker is not installed"
        print_info "Install with: curl -sL https://containerlab.dev/setup | sudo -E bash -s \"all\""
        errors=$((errors + 1))
    fi

    # Check Containerlab
    print_info "Checking Containerlab..."
    if command -v clab &> /dev/null; then
        print_success "Containerlab is installed"
        clab version
    else
        print_error "Containerlab is not installed"
        print_info "Install with: curl -sL https://containerlab.dev/setup | sudo -E bash -s \"all\""
        errors=$((errors + 1))
    fi

    # Check Python
    print_info "Checking Python..."
    if command -v python3 &> /dev/null; then
        print_success "Python3 is installed"
        python3 --version
    else
        print_error "Python3 is not installed"
        errors=$((errors + 1))
    fi

    # Check pip
    print_info "Checking pip..."
    if command -v pip3 &> /dev/null; then
        print_success "pip3 is installed"
    else
        print_warning "pip3 is not installed, will attempt to install"
    fi

    if [ $errors -gt 0 ]; then
        print_error "Prerequisites check failed. Please fix the errors above and re-run."
        exit 1
    fi
}

# Install Python packages
install_python_packages() {
    print_header "Installing Python Packages"

    # Install pip if not present
    if ! command -v pip3 &> /dev/null; then
        print_info "Installing pip3..."
        sudo apt update && sudo apt install -y python3-pip
    fi

    # Install Ansible
    print_info "Installing Ansible..."
    pip3 install --user ansible ansible-core

    # Install required Python packages for AOS-CX
    print_info "Installing Python dependencies for AOS-CX..."
    pip3 install --user requests paramiko pyaoscx

    # Add local bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_info "Adding ~/.local/bin to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Verify Ansible installation
    if command -v ansible &> /dev/null; then
        print_success "Ansible installed successfully"
        ansible --version | head -1
    else
        # Try from .local/bin
        if [ -f "$HOME/.local/bin/ansible" ]; then
            print_success "Ansible installed in ~/.local/bin"
            $HOME/.local/bin/ansible --version | head -1
        else
            print_error "Ansible installation failed"
            exit 1
        fi
    fi
}

# Install Ansible collections
install_ansible_collections() {
    print_header "Installing Ansible Collections"

    # Use ansible-galaxy from PATH or local
    ANSIBLE_GALAXY="ansible-galaxy"
    if ! command -v ansible-galaxy &> /dev/null; then
        ANSIBLE_GALAXY="$HOME/.local/bin/ansible-galaxy"
    fi

    print_info "Installing HPE Aruba AOS-CX collection..."
    $ANSIBLE_GALAXY collection install arubanetworks.aoscx --force

    print_info "Installing community.general collection..."
    $ANSIBLE_GALAXY collection install community.general --force

    print_success "Ansible collections installed"
}

# Check Docker images
check_docker_images() {
    print_header "Checking Docker Images"

    local missing_images=0

    # Check for AOS-CX image
    print_info "Checking for AOS-CX image..."
    if docker images | grep -q "aoscx.*10.15"; then
        print_success "AOS-CX image found"
        docker images | grep aoscx
    else
        print_warning "AOS-CX image not found locally"
        print_info "You need to pull the image from Azure Container Registry:"
        echo ""
        echo "  az acr login --name <your-acr-name>"
        echo "  docker pull <your-acr-name>.azurecr.io/aoscx:10.15.1005"
        echo "  docker tag <your-acr-name>.azurecr.io/aoscx:10.15.1005 aoscx:10.15.1005"
        echo ""
        missing_images=$((missing_images + 1))
    fi

    # Check for Ubuntu SSH image
    print_info "Checking for Ubuntu SSH image..."
    if docker images | grep -q "ubuntu-ssh"; then
        print_success "Ubuntu SSH image found"
        docker images | grep ubuntu-ssh
    else
        print_warning "Ubuntu SSH image not found locally"
        print_info "You need to pull the image from Azure Container Registry:"
        echo ""
        echo "  docker pull <your-acr-name>.azurecr.io/ubuntu-ssh:24.04"
        echo "  docker tag <your-acr-name>.azurecr.io/ubuntu-ssh:24.04 ubuntu-ssh:24.04"
        echo ""
        missing_images=$((missing_images + 1))
    fi

    if [ $missing_images -gt 0 ]; then
        print_warning "Some Docker images are missing. The lab will not deploy until images are available."
    fi
}

# Test Ansible configuration
test_ansible_config() {
    print_header "Testing Ansible Configuration"

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

    print_info "Project directory: $PROJECT_DIR"

    # Check ansible.cfg
    if [ -f "$PROJECT_DIR/ansible.cfg" ]; then
        print_success "ansible.cfg found"
    else
        print_error "ansible.cfg not found"
    fi

    # Check inventory
    if [ -f "$PROJECT_DIR/inventory/hosts.yml" ]; then
        print_success "Inventory file found"
    else
        print_error "Inventory file not found"
    fi

    # Check playbooks directory
    if [ -d "$PROJECT_DIR/playbooks" ]; then
        local playbook_count=$(ls -1 "$PROJECT_DIR/playbooks/"*.yml 2>/dev/null | wc -l)
        print_success "Found $playbook_count playbooks"
    else
        print_error "Playbooks directory not found"
    fi

    # List inventory (should work even without running lab)
    print_info "Validating inventory syntax..."
    cd "$PROJECT_DIR"

    ANSIBLE_CMD="ansible-inventory"
    if ! command -v ansible-inventory &> /dev/null; then
        ANSIBLE_CMD="$HOME/.local/bin/ansible-inventory"
    fi

    if $ANSIBLE_CMD --list > /dev/null 2>&1; then
        print_success "Inventory syntax is valid"
    else
        print_warning "Could not validate inventory (may be normal if lab is not running)"
    fi
}

# Print summary and next steps
print_summary() {
    print_header "Setup Complete!"

    echo -e "${GREEN}Environment setup is complete!${NC}\n"
    echo "Next steps:"
    echo ""
    echo "1. If you haven't already, pull the required Docker images from ACR:"
    echo "   ${YELLOW}az acr login --name <your-acr-name>${NC}"
    echo "   ${YELLOW}docker pull <your-acr-name>.azurecr.io/aoscx:10.15.1005${NC}"
    echo "   ${YELLOW}docker tag <your-acr-name>.azurecr.io/aoscx:10.15.1005 aoscx:10.15.1005${NC}"
    echo ""
    echo "2. Deploy the lab:"
    echo "   ${YELLOW}sudo clab deploy -t lab01.clab.yml${NC}"
    echo ""
    echo "3. Wait 2-3 minutes for switches to boot, then enable REST API:"
    echo "   ${YELLOW}ansible-playbook playbooks/00_setup_rest_api.yml${NC}"
    echo ""
    echo "4. Run the full demo:"
    echo "   ${YELLOW}ansible-playbook playbooks/full_demo.yml${NC}"
    echo ""
    echo "For more information, see README.md"
    echo ""
}

# Main execution
main() {
    print_header "Laketec Ansible Lab - Environment Setup"

    check_not_root
    check_prerequisites
    install_python_packages
    install_ansible_collections
    check_docker_images
    test_ansible_config
    print_summary
}

# Run main function
main "$@"
