#!/bin/bash
set -eu

# List of valid team names
valid_teams=("produits-internes" "conformite" "identite-et-solvabilite" "data" "data-innovation" "alertes" "transverse")

# Colors for output
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No color

# Function to display a header
display_header() {
  echo -e "${CYAN}========================================"
  echo -e " $1"
  echo -e "========================================${NC}"
}

# Function to check if an element is in an array
is_valid_team() {
  local team=$1
  for valid_team in "${valid_teams[@]}"; do
    if [[ "$valid_team" == "$team" ]]; then
      return 0
    fi
  done
  return 1
}

# Function to prompt for corrections
prompt_for_correction() {
  while true; do
    echo -e "${YELLOW}Which value do you want to modify?${NC}"
    echo "1) Service Name"
    echo "2) Project Name"
    echo "3) Namespace"
    echo "4) Team Name"
    echo "5) Tag Version (stg)"
    echo "6) Server Name (stg)"
    echo "7) Tag Version (prd)"
    echo "8) Server Name (prd)"
    echo "9) Registry Image"
    echo "10) CPU Request"
    echo "11) Memory Request"
    echo "12) CPU Limit"
    echo "13) Memory Limit"
    echo "0) Finish corrections"

    read -p "Enter the number of the field to modify: " choice
    case $choice in
      1) read -p "Enter the service name: " service_name ;;
      2) read -p "Enter the project name: " project_name ;;
      3) read -p "Enter the project namespace: " namespace ;;
      4)
        while true; do
          read -p "Enter the team name (${valid_teams[*]}): " team_name
          if is_valid_team "$team_name"; then
            echo -e "${GREEN}Team name accepted: ${team_name}${NC}"
            break
          else
            echo -e "${RED}Invalid team name. Accepted values: ${valid_teams[*]}${NC}"
          fi
        done
        ;;
      5) read -p "Enter the tag version for staging (stg): " tag_version_stg ;;
      6) read -p "Enter the server name for staging (stg): " server_name_stg ;;
      7) read -p "Enter the tag version for production (prd): " tag_version_prd ;;
      8) read -p "Enter the server name for production (prd): " server_name_prd ;;
      9) read -p "Enter the registry image: " registry_image ;;
      10) echo -e "${YELLOW}Enter CPU request: ${NC}"
          read -p "CPU request: " cpu_request ;;
      11) echo -e "${YELLOW}Enter Memory request: ${NC}"
          read -p "Memory request: " memory_request ;;
      12) read -p "Enter CPU limit: " cpu_limit ;;
      13) read -p "Enter Memory limit: " memory_limit ;;
      0) break ;;
      *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
  done
}

# Function to create project structure from templates
create_structure() {
  display_header "Step 4: Generating project files"

  ################## BASE #####################
  echo -e "${YELLOW}Generating base files...${NC}"
  local uri="apps/base/${service_name}/api"
  mkdir -p ${uri}

  export project_name="$project_name"
  export namespace="$namespace"
  export service_name="$service_name"
  export team_name="${team_name}"
  export repository_image="${registry_image}"
  export cpu_request="${cpu_request}"
  export memory_request="${memory_request}"
  export cpu_limit="${cpu_limit}"
  export memory_limit="${memory_limit}"

  cat "templates/base/hr-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/hr-${project_name}.yaml"

  # Generating base/project_name/kustomization.yaml
  base_kustomization_content="apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - hr-${project_name}.yaml"
  echo "$base_kustomization_content" > "${uri}/kustomization.yaml"
  echo -e "${GREEN}Base files generated successfully.${NC}\n"

  ################## STAGING ##########################
  echo -e "${YELLOW}Generating staging files...${NC}"
  uri="apps/staging/${namespace}/${service_name}"
  mkdir -p "${uri}/api" "${uri}/automations"

  export server_name="${server_name_stg}"
  export tag="${tag_version_stg}"
  export env="stg"
  export env_full="staging"
  export policy_pattern='^v?(?P<rv>[0-9]+\.[0-9]+\.[0-9]+-(?:alpha|beta|rc)\.[0-9]+)$'
  export policy_range='^1.x.x-0'
  export project_branch_iua_destination="main"
  export project_name="$project_name"
  export namespace="$namespace"
  export service_name="$service_name"
  export team_name="${team_name}"
  export repository_image="${registry_image}"

  cat "templates/app/api/hr-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/api/hr-${project_name}.yaml"
  cat "templates/app/automations/iua-service.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/iua-${service_name}.yaml"
  cat "templates/app/automations/policy-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/policy-${project_name}.yaml"
  cat "templates/app/automations/receiver-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/receiver-${project_name}.yaml"
  cat "templates/app/automations/registry-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/registry-${project_name}.yaml"

  api_kustomization_content="---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../../base/${service_name}/api
patches:
  - path: hr-${project_name}.yaml"

  automations_kustomization_content="---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - iua-${service_name}.yaml
  - policy-${project_name}.yaml
  - registry-${project_name}.yaml
  - receiver-${project_name}.yaml"

  service_kustomization="---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${namespace}
resources:
  - api
  - automations
"
  echo "$api_kustomization_content" > "${uri}/api/kustomization.yaml"
  echo "$automations_kustomization_content" > "${uri}/automations/kustomization.yaml"
  echo "$service_kustomization" > "${uri}/kustomization.yaml"

  echo -e "${GREEN}Staging files generated successfully.${NC}\n"

  ################### PRODUCTION ###################
  echo -e "${YELLOW}Generating production files...${NC}"
  uri="apps/production/${namespace}/${service_name}"
  mkdir -p "${uri}/api" "${uri}/automations"

  export server_name="${server_name_prd}"
  export tag="${tag_version_prd}"
  export env="prd"
  export env_full="production"
  export policy_pattern='^v?(?P<rv>[0-9]+\.[0-9]+\.[0-9]+)$'
  export policy_range='^1.x.x'
  export project_branch_iua_destination="deploy/${service_name}-prd"
  export project_name="$project_name"
  export namespace="$namespace"
  export service_name="$service_name"
  export team_name="${team_name}"
  export repository_image="${registry_image}"

  cat "templates/app/api/hr-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/api/hr-${project_name}.yaml"
  cat "templates/app/automations/iua-service.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/iua-${service_name}.yaml"
  cat "templates/app/automations/policy-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/policy-${project_name}.yaml"
  cat "templates/app/automations/registry-php-api.yaml" | envsubst | sed -e 's/§/$/g' > "${uri}/automations/registry-${project_name}.yaml"

  api_kustomization_content="---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../../base/${service_name}/api
patches:
  - path: hr-${project_name}.yaml"

  automations_kustomization_content="---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - iua-${service_name}.yaml
  - policy-${project_name}.yaml
  - registry-${project_name}.yaml

  service_kustomization="---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${namespace}
resources:
  - api
  - automations
"
  echo "$api_kustomization_content" > "${uri}/api/kustomization.yaml"
  echo "$automations_kustomization_content" > "${uri}/automations/kustomization.yaml"
  echo "$service_kustomization" > "${uri}/kustomization.yaml"

  echo -e "${GREEN}Production files generated successfully.${NC}\n"

}

# Start of script execution
display_header "Step 1: Collecting project details"
read -p "Enter the service name: " service_name
read -p "Enter the project name: " project_name
read -p "Enter the project namespace: " namespace

# Validate team name
while true; do
  read -p "Enter the team name (${valid_teams[*]}): " team_name
  if is_valid_team "$team_name"; then
    echo -e "${GREEN}Team name accepted: ${team_name}${NC}"
    break
  else
    echo -e "${RED}Invalid team name. Accepted values: ${valid_teams[*]}${NC}"
  fi
done

# Prompt for tag versions and server names
read -p "Enter the tag version for staging (stg): " tag_version_stg
read -p "Enter the server name for staging (stg): " server_name_stg
read -p "Enter the tag version for production (prd): " tag_version_prd
read -p "Enter the server name for production (prd): " server_name_prd

# Prompt for registry image
read -p "Enter the registry image: " registry_image

# Prompt for resource requests and limits with examples
echo -e "${YELLOW}Enter CPU request (ex 300m): ${NC}"
read -p "CPU request: " cpu_request

echo -e "${YELLOW}Enter Memory request (ex 400Mi): ${NC}"
read -p "Memory request: " memory_request

read -p "Enter CPU limit: " cpu_limit
read -p "Enter Memory limit: " memory_limit

# Confirm values
while true; do
  display_header "Step 2: Confirming entered values"
  echo -e "Service Name    : ${CYAN}${service_name}${NC}"
  echo -e "Project Name    : ${CYAN}${project_name}${NC}"
  echo -e "Namespace       : ${CYAN}${namespace}${NC}"
  echo -e "Team Name       : ${CYAN}${team_name}${NC}"
  echo -e "Tag Version (stg) : ${CYAN}${tag_version_stg}${NC}"
  echo -e "Server Name (stg) : ${CYAN}${server_name_stg}${NC}"
  echo -e "Tag Version (prd) : ${CYAN}${tag_version_prd}${NC}"
  echo -e "Server Name (prd) : ${CYAN}${server_name_prd}${NC}"
  echo -e "Registry Image  : ${CYAN}${registry_image}${NC}"
  echo -e "CPU Request     : ${CYAN}${cpu_request}${NC}"
  echo -e "Memory Request  : ${CYAN}${memory_request}${NC}"
  echo -e "CPU Limit       : ${CYAN}${cpu_limit}${NC}"
  echo -e "Memory Limit    : ${CYAN}${memory_limit}${NC}"
  echo
  read -p "Are these values correct? (y/n): " confirmation
  if [[ "$confirmation" == "y" ]]; then
    break
  else
    prompt_for_correction
  fi
done

display_header "Step 3: Checking required directories"
directories=("apps/base" "apps/staging/$namespace" "apps/production/$namespace")

# Check each directory and create project structure if exists
for dir in "${directories[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${GREEN}Directory exists: $dir${NC}"
  else
    echo -e "${RED}Directory does not exist: $dir${NC}"
    echo -e "${RED}Bye bye${NC}"
    exit 1
  fi
done

# Create the project structure
create_structure

echo -e "${GREEN}Bye bye${NC}"
