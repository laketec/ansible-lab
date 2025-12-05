#!/bin/bash
# =============================================================================
# Laketec Ansible Lab - Pull Docker Images from Azure Container Registry
# =============================================================================
# This script pulls the required Docker images from ACR and tags them locally.
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==============================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Default ACR name - modify this for your organization
DEFAULT_ACR_NAME="laketecacr"

# Get ACR name from argument or use default
ACR_NAME="${1:-$DEFAULT_ACR_NAME}"

print_header "Pull Docker Images from Azure Container Registry"

echo "ACR Name: $ACR_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed"
    print_info "Install with: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Check if logged into Azure
print_info "Checking Azure login status..."
if ! az account show &> /dev/null; then
    print_info "Not logged into Azure. Starting login..."
    az login
fi

# Login to ACR
print_info "Logging into Azure Container Registry: $ACR_NAME..."
az acr login --name "$ACR_NAME"

# Pull AOS-CX image
print_header "Pulling AOS-CX Image"
print_info "Pulling ${ACR_NAME}.azurecr.io/aoscx:10.15.1005..."
docker pull "${ACR_NAME}.azurecr.io/aoscx:10.15.1005"

print_info "Tagging image as aoscx:10.15.1005..."
docker tag "${ACR_NAME}.azurecr.io/aoscx:10.15.1005" aoscx:10.15.1005

print_success "AOS-CX image ready"

# Pull Ubuntu SSH image
print_header "Pulling Ubuntu SSH Image"
print_info "Pulling ${ACR_NAME}.azurecr.io/ubuntu-ssh:24.04..."
docker pull "${ACR_NAME}.azurecr.io/ubuntu-ssh:24.04"

print_info "Tagging image as ubuntu-ssh:24.04..."
docker tag "${ACR_NAME}.azurecr.io/ubuntu-ssh:24.04" ubuntu-ssh:24.04

print_success "Ubuntu SSH image ready"

# Verify images
print_header "Verifying Docker Images"
echo "Available images:"
docker images | grep -E "aoscx|ubuntu-ssh" || true

print_header "Complete!"
echo -e "${GREEN}All images have been pulled and tagged successfully!${NC}"
echo ""
echo "You can now deploy the lab with:"
echo "  ${YELLOW}sudo clab deploy -t lab01.clab.yml${NC}"
echo ""
