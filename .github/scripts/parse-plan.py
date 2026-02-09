#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# parse-plan.py - Terraform Plan JSON Parser
# -----------------------------------------------------------------------------
# Purpose: Parses Terraform plan JSON output to count resource changes, detect
# destructive operations (VM replacements, network changes, public IPs), and
# assign a risk level.
#
# Risk levels:
#   LOW    - Only additions, no changes or deletions
#   MEDIUM - Changes or updates present, but no deletions
#   HIGH   - Resource deletions, replacements, or destructive operations
#
# Usage:
#   python parse-plan.py <path-to-tfplan.json>    # from file argument
#   cat tfplan.json | python parse-plan.py -       # from stdin
#   cat tfplan.json | python parse-plan.py         # from stdin (no args)
#
# Output (JSON to stdout):
#   {
#     "risk_level": "MEDIUM",
#     "requires_approval": true,
#     "add": 5,
#     "change": 2,
#     "destroy": 0,
#     "replace": 0,
#     "destructive_operations": [...],
#     "security_changes": [...],
#     "details": {
#       "resources_added": [...],
#       "resources_changed": [...],
#       "resources_destroyed": [...],
#       "resources_replaced": [...]
#     }
#   }
#
# Dependencies: Python 3.11+ stdlib only (json, sys, os)
# -----------------------------------------------------------------------------

import json
import os
import sys
from typing import Any

# ---------------------------------------------------------------------------
# Resource types that represent destructive or high-risk operations when
# modified, replaced, or destroyed.
# ---------------------------------------------------------------------------

# VM and compute resources -- replacement means downtime
VM_RESOURCE_TYPES = {
    "azurerm_virtual_machine",
    "azurerm_linux_virtual_machine",
    "azurerm_windows_virtual_machine",
    "azurerm_virtual_machine_scale_set",
    "azurerm_linux_virtual_machine_scale_set",
    "azurerm_windows_virtual_machine_scale_set",
    "azurerm_managed_disk",
    "azurerm_virtual_machine_data_disk_attachment",
}

# Network resources -- changes can break connectivity
NETWORK_RESOURCE_TYPES = {
    "azurerm_virtual_network",
    "azurerm_virtual_network_peering",
    "azurerm_subnet",
    "azurerm_network_interface",
    "azurerm_network_security_group",
    "azurerm_network_security_rule",
    "azurerm_route_table",
    "azurerm_route",
    "azurerm_application_gateway",
    "azurerm_firewall",
    "azurerm_firewall_policy",
    "azurerm_nat_gateway",
    "azurerm_private_endpoint",
    "azurerm_private_dns_zone",
    "azurerm_private_dns_zone_virtual_network_link",
    "azurerm_bastion_host",
    "azurerm_express_route_circuit",
    "azurerm_virtual_network_gateway",
    "azurerm_vpn_gateway",
    "azurerm_lb",
    "azurerm_lb_rule",
}

# Public IP resources -- exposure risk
PUBLIC_IP_RESOURCE_TYPES = {
    "azurerm_public_ip",
    "azurerm_public_ip_prefix",
}

# Security-relevant resources -- changes require careful review
SECURITY_RESOURCE_TYPES = {
    "azurerm_network_security_group",
    "azurerm_network_security_rule",
    "azurerm_public_ip",
    "azurerm_public_ip_prefix",
    "azurerm_key_vault",
    "azurerm_key_vault_access_policy",
    "azurerm_key_vault_key",
    "azurerm_key_vault_secret",
    "azurerm_role_assignment",
    "azurerm_role_definition",
    "azurerm_user_assigned_identity",
    "azurerm_policy_assignment",
    "azurerm_policy_definition",
    "azurerm_firewall",
    "azurerm_firewall_policy",
    "azurerm_firewall_policy_rule_collection_group",
}

# All high-risk resource types (union of destructive categories)
HIGH_RISK_RESOURCE_TYPES = VM_RESOURCE_TYPES | NETWORK_RESOURCE_TYPES | PUBLIC_IP_RESOURCE_TYPES


def load_plan(plan_source: str | None) -> dict[str, Any]:
    """Load a Terraform plan JSON from a file path or stdin.

    Args:
        plan_source: Path to the plan JSON file. Use "-" or None to read
                     from stdin.

    Returns:
        Parsed plan JSON as a dictionary.

    Raises:
        FileNotFoundError: If the plan file does not exist.
        json.JSONDecodeError: If the input is not valid JSON.
    """
    if plan_source is None or plan_source == "-":
        raw = sys.stdin.read()
        if not raw.strip():
            print("Error: No input received on stdin", file=sys.stderr)
            sys.exit(1)
        return json.loads(raw)

    if not os.path.isfile(plan_source):
        raise FileNotFoundError(f"Plan file not found: {plan_source}")

    with open(plan_source, "r", encoding="utf-8") as f:
        return json.load(f)


def classify_resource(resource: dict[str, Any]) -> dict[str, Any] | None:
    """Classify a single resource change entry.

    Args:
        resource: A single entry from the plan's resource_changes array.

    Returns:
        A classification dict with address, type, actions, and flags, or
        None if the resource should be skipped (data sources, no-ops).
    """
    # Skip data sources -- they are read-only lookups, not managed resources
    if resource.get("mode", "") == "data":
        return None

    change = resource.get("change", {})
    actions = change.get("actions", [])
    address = resource.get("address", "unknown")
    resource_type = resource.get("type", "unknown")

    # Skip no-ops and read-only
    if actions in (["no-op"], ["read"]):
        return None

    # Determine the action category
    if actions == ["create"]:
        category = "add"
    elif actions == ["update"]:
        category = "change"
    elif actions == ["delete"]:
        category = "destroy"
    elif actions == ["delete", "create"] or actions == ["create", "delete"]:
        category = "replace"
    elif "delete" in actions:
        category = "destroy"
    elif "update" in actions or "create" in actions:
        category = "change"
    else:
        # Unknown action type -- treat as a change for safety
        category = "change"

    # Detect destructive operations on high-risk resources
    is_destructive = False
    destructive_reason = None

    if category in ("destroy", "replace"):
        is_destructive = True
        if resource_type in VM_RESOURCE_TYPES:
            destructive_reason = "VM replacement/deletion causes downtime"
        elif resource_type in NETWORK_RESOURCE_TYPES:
            destructive_reason = "Network change may break connectivity"
        elif resource_type in PUBLIC_IP_RESOURCE_TYPES:
            destructive_reason = "Public IP change affects external access"
        else:
            destructive_reason = "Resource deletion or replacement"
    elif category == "change" and resource_type in HIGH_RISK_RESOURCE_TYPES:
        # In-place changes to high-risk resources are still noteworthy
        is_destructive = False
        destructive_reason = None

    # Detect security-relevant changes
    is_security_change = (
        resource_type in SECURITY_RESOURCE_TYPES and category != "add"
    )

    # Detect public IP additions (new public exposure)
    is_public_ip_addition = (
        resource_type in PUBLIC_IP_RESOURCE_TYPES and category == "add"
    )

    return {
        "address": address,
        "type": resource_type,
        "actions": actions,
        "category": category,
        "is_destructive": is_destructive,
        "destructive_reason": destructive_reason,
        "is_security_change": is_security_change,
        "is_public_ip_addition": is_public_ip_addition,
    }


def parse_plan(plan: dict[str, Any]) -> dict[str, Any]:
    """Parse a Terraform plan dict and return risk assessment.

    Args:
        plan: Parsed Terraform plan JSON dictionary.

    Returns:
        Dictionary containing risk level, approval requirement, resource
        counts, destructive operation details, and resource lists.
    """
    # Initialize counters
    add_count = 0
    change_count = 0
    destroy_count = 0
    replace_count = 0

    # Initialize detail lists
    resources_added: list[dict[str, Any]] = []
    resources_changed: list[dict[str, Any]] = []
    resources_destroyed: list[dict[str, Any]] = []
    resources_replaced: list[dict[str, Any]] = []

    # Track destructive operations and security changes
    destructive_operations: list[dict[str, str]] = []
    security_changes: list[dict[str, str]] = []

    # Extract resource changes from the plan
    resource_changes = plan.get("resource_changes", [])

    for resource in resource_changes:
        classified = classify_resource(resource)
        if classified is None:
            continue

        resource_info = {
            "address": classified["address"],
            "type": classified["type"],
            "actions": classified["actions"],
        }

        category = classified["category"]

        if category == "add":
            add_count += 1
            resources_added.append(resource_info)
        elif category == "change":
            change_count += 1
            resources_changed.append(resource_info)
        elif category == "destroy":
            destroy_count += 1
            resources_destroyed.append(resource_info)
        elif category == "replace":
            replace_count += 1
            resources_replaced.append(resource_info)

        # Record destructive operations
        if classified["is_destructive"]:
            destructive_operations.append({
                "address": classified["address"],
                "type": classified["type"],
                "actions": classified["actions"],
                "reason": classified["destructive_reason"] or "Destructive operation",
            })

        # Record security-relevant changes
        if classified["is_security_change"]:
            security_changes.append({
                "address": classified["address"],
                "type": classified["type"],
                "actions": classified["actions"],
            })

        # Record new public IP additions as security-notable
        if classified["is_public_ip_addition"]:
            security_changes.append({
                "address": classified["address"],
                "type": classified["type"],
                "actions": classified["actions"],
            })

    # Determine risk level
    risk_level = determine_risk_level(
        add_count, change_count, destroy_count, replace_count,
        destructive_operations, security_changes,
    )

    # Determine if approval is required (MEDIUM and HIGH need approval)
    requires_approval = risk_level in ("MEDIUM", "HIGH")

    # Build summary string
    summary_parts = []
    if add_count > 0:
        summary_parts.append(f"{add_count} to add")
    if change_count > 0:
        summary_parts.append(f"{change_count} to change")
    if destroy_count > 0:
        summary_parts.append(f"{destroy_count} to destroy")
    if replace_count > 0:
        summary_parts.append(f"{replace_count} to replace")
    summary = ", ".join(summary_parts) if summary_parts else "No changes"

    result = {
        "risk_level": risk_level,
        "requires_approval": requires_approval,
        "add": add_count,
        "change": change_count,
        "destroy": destroy_count,
        "replace": replace_count,
        "summary": summary,
        "destructive_operations": destructive_operations,
        "security_changes": security_changes,
        "details": {
            "resources_added": resources_added,
            "resources_changed": resources_changed,
            "resources_destroyed": resources_destroyed,
            "resources_replaced": resources_replaced,
        },
    }

    return result


def determine_risk_level(
    add: int,
    change: int,
    destroy: int,
    replace: int,
    destructive_operations: list[dict[str, Any]],
    security_changes: list[dict[str, Any]],
) -> str:
    """Determine the risk level based on resource change counts and types.

    Args:
        add: Number of resources being added.
        change: Number of resources being changed/updated.
        destroy: Number of resources being destroyed.
        replace: Number of resources being replaced (destroy + recreate).
        destructive_operations: List of detected destructive operations.
        security_changes: List of detected security-relevant changes.

    Returns:
        Risk level string: "LOW", "MEDIUM", or "HIGH".
    """
    # HIGH: Any deletions or replacements
    if destroy > 0 or replace > 0:
        return "HIGH"

    # HIGH: Destructive operations detected on high-risk resources
    if len(destructive_operations) > 0:
        return "HIGH"

    # MEDIUM: Changes/updates present but no deletions
    if change > 0:
        return "MEDIUM"

    # MEDIUM: Security-relevant changes (e.g., new public IPs)
    if len(security_changes) > 0:
        return "MEDIUM"

    # LOW: Only additions (or no changes at all)
    return "LOW"


def set_github_output(result: dict[str, Any]) -> None:
    """Write key values to GITHUB_OUTPUT for use in subsequent workflow steps.

    Each key-value pair is written as a separate line in the format
    expected by GitHub Actions (key=value).

    Args:
        result: The parsed plan result dictionary.
    """
    github_output = os.environ.get("GITHUB_OUTPUT")
    if not github_output:
        return

    with open(github_output, "a", encoding="utf-8") as f:
        f.write(f"risk_level={result['risk_level']}\n")
        f.write(f"requires_approval={str(result['requires_approval']).lower()}\n")
        f.write(f"add={result['add']}\n")
        f.write(f"change={result['change']}\n")
        f.write(f"destroy={result['destroy']}\n")
        f.write(f"replace={result['replace']}\n")
        f.write(f"summary={result['summary']}\n")
        # Write the full JSON result as a single-line value
        f.write(f"result={json.dumps(result, separators=(',', ':'))}\n")


def main() -> None:
    """Entry point: parse command-line arguments and run the plan parser."""
    plan_source: str | None = None

    if len(sys.argv) == 2:
        plan_source = sys.argv[1]
    elif len(sys.argv) == 1:
        # No arguments: read from stdin
        if sys.stdin.isatty():
            print(
                f"Usage: {sys.argv[0]} <path-to-tfplan.json>",
                file=sys.stderr,
            )
            print(
                f"       cat tfplan.json | {sys.argv[0]} -",
                file=sys.stderr,
            )
            sys.exit(1)
        plan_source = None  # Will read from stdin
    else:
        print(
            f"Usage: {sys.argv[0]} <path-to-tfplan.json>",
            file=sys.stderr,
        )
        print(
            f"       cat tfplan.json | {sys.argv[0]} -",
            file=sys.stderr,
        )
        sys.exit(1)

    # Validate file exists when a path is provided (not stdin)
    if plan_source is not None and plan_source != "-" and not os.path.isfile(plan_source):
        print(f"Error: Plan file not found: {plan_source}", file=sys.stderr)
        sys.exit(1)

    try:
        plan = load_plan(plan_source)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in plan input: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    result = parse_plan(plan)

    # Print the result as formatted JSON to stdout
    print(json.dumps(result, indent=2))

    # Set GitHub Actions output variables if running in CI
    set_github_output(result)

    # Print warning to stderr if risk level is HIGH
    if result["risk_level"] == "HIGH":
        print(
            "\nWARNING: HIGH risk changes detected. Manual approval recommended.",
            file=sys.stderr,
        )
        if result["destructive_operations"]:
            print("\nDestructive operations detected:", file=sys.stderr)
            for op in result["destructive_operations"]:
                print(f"  - {op['address']}: {op['reason']}", file=sys.stderr)

    if result["security_changes"]:
        print("\nSecurity-relevant changes detected:", file=sys.stderr)
        for sc in result["security_changes"]:
            print(f"  - {sc['address']} ({sc['type']})", file=sys.stderr)


if __name__ == "__main__":
    main()
