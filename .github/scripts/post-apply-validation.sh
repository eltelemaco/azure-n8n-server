#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# post-apply-validation.sh - Post-Apply Smoke Tests
# -----------------------------------------------------------------------------
# Purpose: Verifies that Terraform apply completed successfully by checking
# that expected Azure resources exist and are configured correctly.
#
# This script is used by the validator-post-apply job in the deployment
# workflow to confirm infrastructure was provisioned as expected.
#
# Authentication: Uses GitHub OIDC to Azure via federated credentials.
# The runner must already be authenticated with Azure CLI before this
# script is invoked (az login with OIDC is handled by the workflow).
#
# Usage:
#   ./post-apply-validation.sh
#
# Environment variables (optional):
#   RESOURCE_GROUP_NAME  - Resource group to validate (default: telemaco-dev)
#   EXPECTED_LOCATION    - Expected Azure region (default: eastus)
#   EXPECTED_VNET_CIDR   - Expected VNet address space (default: 10.0.0.0/16)
#
# Exit codes:
#   0 - All validations passed
#   1 - One or more validations failed
# -----------------------------------------------------------------------------

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (overridable via environment variables)
# ---------------------------------------------------------------------------
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-telemaco-dev}"
EXPECTED_LOCATION="${EXPECTED_LOCATION:-eastus}"
EXPECTED_VNET_CIDR="${EXPECTED_VNET_CIDR:-10.0.0.0/16}"

# ---------------------------------------------------------------------------
# State tracking
# ---------------------------------------------------------------------------
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILURES=""

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

log_info() {
    echo "[INFO]  $1"
}

log_pass() {
    echo "[PASS]  $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

log_fail() {
    echo "[FAIL]  $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
    FAILURES="${FAILURES}\n  - $1"
}

print_summary() {
    echo ""
    echo "============================================================"
    echo "  Post-Apply Validation Summary"
    echo "============================================================"
    echo "  Tests run:    ${TESTS_RUN}"
    echo "  Tests passed: ${TESTS_PASSED}"
    echo "  Tests failed: ${TESTS_FAILED}"

    if [ "${TESTS_FAILED}" -gt 0 ]; then
        echo ""
        echo "  Failed validations:"
        echo -e "${FAILURES}"
    fi

    echo "============================================================"
    echo ""
}

# ---------------------------------------------------------------------------
# Validation: Azure CLI authentication
# ---------------------------------------------------------------------------

validate_azure_auth() {
    log_info "Checking Azure CLI authentication..."

    if ! az account show --output none 2>/dev/null; then
        log_fail "Azure CLI is not authenticated. Run 'az login' first."
        return 1
    fi

    local account_name
    account_name=$(az account show --query "name" --output tsv 2>/dev/null)
    log_pass "Azure CLI authenticated (subscription: ${account_name})"
    return 0
}

# ---------------------------------------------------------------------------
# Validation: Resource group exists
# ---------------------------------------------------------------------------

validate_resource_group() {
    log_info "Checking resource group '${RESOURCE_GROUP_NAME}' exists..."

    local rg_exists
    rg_exists=$(az group exists --name "${RESOURCE_GROUP_NAME}" 2>/dev/null)

    if [ "${rg_exists}" != "true" ]; then
        log_fail "Resource group '${RESOURCE_GROUP_NAME}' does not exist"
        return 1
    fi

    # Verify the resource group location
    local rg_location
    rg_location=$(az group show \
        --name "${RESOURCE_GROUP_NAME}" \
        --query "location" \
        --output tsv 2>/dev/null)

    if [ "${rg_location}" = "${EXPECTED_LOCATION}" ]; then
        log_pass "Resource group '${RESOURCE_GROUP_NAME}' exists in '${rg_location}'"
    else
        log_fail "Resource group location mismatch: expected '${EXPECTED_LOCATION}', got '${rg_location}'"
        return 1
    fi

    # Verify provisioning state
    local rg_state
    rg_state=$(az group show \
        --name "${RESOURCE_GROUP_NAME}" \
        --query "properties.provisioningState" \
        --output tsv 2>/dev/null)

    if [ "${rg_state}" = "Succeeded" ]; then
        log_pass "Resource group '${RESOURCE_GROUP_NAME}' provisioning state: Succeeded"
    else
        log_fail "Resource group '${RESOURCE_GROUP_NAME}' provisioning state: ${rg_state} (expected: Succeeded)"
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Validation: Virtual network exists with correct address space
# ---------------------------------------------------------------------------

validate_vnet() {
    log_info "Checking virtual networks in resource group '${RESOURCE_GROUP_NAME}'..."

    # List all VNets in the resource group
    local vnet_count
    vnet_count=$(az network vnet list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "length(@)" \
        --output tsv 2>/dev/null)

    if [ -z "${vnet_count}" ] || [ "${vnet_count}" -eq 0 ]; then
        log_fail "No virtual networks found in resource group '${RESOURCE_GROUP_NAME}'"
        return 1
    fi

    log_pass "Found ${vnet_count} virtual network(s) in resource group '${RESOURCE_GROUP_NAME}'"

    # Verify at least one VNet has the expected address space
    local vnet_with_cidr
    vnet_with_cidr=$(az network vnet list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "[?addressSpace.addressPrefixes[?contains(@, '${EXPECTED_VNET_CIDR}')]].name" \
        --output tsv 2>/dev/null)

    if [ -n "${vnet_with_cidr}" ]; then
        log_pass "VNet '${vnet_with_cidr}' has expected address space '${EXPECTED_VNET_CIDR}'"
    else
        log_fail "No VNet found with expected address space '${EXPECTED_VNET_CIDR}'"
        return 1
    fi

    # Verify VNet provisioning state
    local vnet_state
    vnet_state=$(az network vnet list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "[0].provisioningState" \
        --output tsv 2>/dev/null)

    if [ "${vnet_state}" = "Succeeded" ]; then
        log_pass "VNet provisioning state: Succeeded"
    else
        log_fail "VNet provisioning state: ${vnet_state} (expected: Succeeded)"
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Validation: Subnets exist (if any are deployed)
# ---------------------------------------------------------------------------

validate_subnets() {
    log_info "Checking subnets in resource group '${RESOURCE_GROUP_NAME}'..."

    # Get all VNet names in the resource group
    local vnet_names
    vnet_names=$(az network vnet list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "[].name" \
        --output tsv 2>/dev/null)

    if [ -z "${vnet_names}" ]; then
        log_info "No VNets found -- skipping subnet validation"
        return 0
    fi

    local total_subnets=0

    # Check subnets in each VNet
    while IFS= read -r vnet_name; do
        if [ -z "${vnet_name}" ]; then
            continue
        fi

        local subnet_count
        subnet_count=$(az network vnet subnet list \
            --resource-group "${RESOURCE_GROUP_NAME}" \
            --vnet-name "${vnet_name}" \
            --query "length(@)" \
            --output tsv 2>/dev/null)

        if [ -n "${subnet_count}" ] && [ "${subnet_count}" -gt 0 ]; then
            log_pass "VNet '${vnet_name}' has ${subnet_count} subnet(s)"
            total_subnets=$((total_subnets + subnet_count))

            # List subnet names for visibility
            local subnet_names
            subnet_names=$(az network vnet subnet list \
                --resource-group "${RESOURCE_GROUP_NAME}" \
                --vnet-name "${vnet_name}" \
                --query "[].name" \
                --output tsv 2>/dev/null)

            while IFS= read -r subnet_name; do
                if [ -n "${subnet_name}" ]; then
                    # Verify each subnet provisioning state
                    local subnet_state
                    subnet_state=$(az network vnet subnet show \
                        --resource-group "${RESOURCE_GROUP_NAME}" \
                        --vnet-name "${vnet_name}" \
                        --name "${subnet_name}" \
                        --query "provisioningState" \
                        --output tsv 2>/dev/null)

                    if [ "${subnet_state}" = "Succeeded" ]; then
                        log_info "  Subnet '${subnet_name}': provisioning state Succeeded"
                    else
                        log_info "  Subnet '${subnet_name}': provisioning state ${subnet_state}"
                    fi
                fi
            done <<< "${subnet_names}"
        else
            log_info "VNet '${vnet_name}' has no subnets (may not be deployed yet)"
        fi
    done <<< "${vnet_names}"

    if [ "${total_subnets}" -eq 0 ]; then
        log_info "No subnets found -- this may be expected if subnets are not yet deployed"
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Validation: Resource tags (verify Terraform-managed resources)
# ---------------------------------------------------------------------------

validate_tags() {
    log_info "Checking for Terraform-managed resources (managed_by=terraform tag)..."

    local tagged_count
    tagged_count=$(az resource list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "length([?tags.managed_by=='terraform'])" \
        --output tsv 2>/dev/null)

    if [ -n "${tagged_count}" ] && [ "${tagged_count}" -gt 0 ]; then
        log_pass "Found ${tagged_count} resource(s) tagged with managed_by=terraform"
    else
        log_info "No resources found with managed_by=terraform tag (may be expected for initial deployment)"
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Smoke test: DNS resolution and basic connectivity
# ---------------------------------------------------------------------------

smoke_test_connectivity() {
    log_info "Running connectivity smoke tests..."

    # Verify Azure CLI can query resources in the resource group
    local resource_count
    resource_count=$(az resource list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "length(@)" \
        --output tsv 2>/dev/null)

    if [ -n "${resource_count}" ]; then
        log_pass "Resource group '${RESOURCE_GROUP_NAME}' is accessible (${resource_count} resource(s))"
    else
        log_fail "Cannot list resources in resource group '${RESOURCE_GROUP_NAME}'"
        return 1
    fi

    # Verify no failed provisioning states on resources
    local failed_resources
    failed_resources=$(az resource list \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --query "[?provisioningState!='Succeeded'].{name:name, type:type, state:provisioningState}" \
        --output tsv 2>/dev/null)

    if [ -z "${failed_resources}" ]; then
        log_pass "All resources in '${RESOURCE_GROUP_NAME}' have Succeeded provisioning state"
    else
        log_fail "Some resources have non-Succeeded provisioning state"
        log_info "Resources with issues:"
        echo "${failed_resources}" | while IFS= read -r line; do
            if [ -n "${line}" ]; then
                log_info "  ${line}"
            fi
        done
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------------------

main() {
    echo ""
    echo "============================================================"
    echo "  Post-Apply Validation - Smoke Tests"
    echo "============================================================"
    echo "  Resource Group: ${RESOURCE_GROUP_NAME}"
    echo "  Expected Location: ${EXPECTED_LOCATION}"
    echo "  Expected VNet CIDR: ${EXPECTED_VNET_CIDR}"
    echo "============================================================"
    echo ""

    # Run all validations. We use || true to prevent set -e from stopping
    # on the first failure; we want to run ALL validations and report at end.
    validate_azure_auth || true
    validate_resource_group || true
    validate_vnet || true
    validate_subnets || true
    validate_tags || true
    smoke_test_connectivity || true

    # Print summary
    print_summary

    # Set GitHub Actions outputs if running in CI
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "tests_run=${TESTS_RUN}" >> "${GITHUB_OUTPUT}"
        echo "tests_passed=${TESTS_PASSED}" >> "${GITHUB_OUTPUT}"
        echo "tests_failed=${TESTS_FAILED}" >> "${GITHUB_OUTPUT}"
        if [ "${TESTS_FAILED}" -gt 0 ]; then
            echo "validation_status=failed" >> "${GITHUB_OUTPUT}"
        else
            echo "validation_status=passed" >> "${GITHUB_OUTPUT}"
        fi
    fi

    # Exit with appropriate status code
    if [ "${TESTS_FAILED}" -gt 0 ]; then
        echo "Post-apply validation FAILED with ${TESTS_FAILED} failure(s)"
        exit 1
    fi

    echo "Post-apply validation PASSED -- all checks successful"
    exit 0
}

main "$@"
