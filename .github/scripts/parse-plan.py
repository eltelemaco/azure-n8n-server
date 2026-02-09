#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# parse-plan.py - Terraform Plan JSON Parser
# -----------------------------------------------------------------------------
# Purpose: Parses Terraform plan JSON output to count resource changes, detect
# destructive operations (replacements, deletions), and assign a risk level.
#
# Risk levels:
#   LOW    - Only additions, no changes or deletions
#   MEDIUM - Changes or updates present, but no deletions
#   HIGH   - Resource deletions or replacements detected
#
# Usage:
#   python parse-plan.py <path-to-tfplan.json>
#
# Output (JSON to stdout):
#   {
#     "risk_level": "MEDIUM",
#     "requires_approval": true,
#     "add": 5,
#     "change": 2,
#     "destroy": 0,
#     "replace": 0,
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


def parse_plan(plan_path: str) -> dict:
    """Parse a Terraform plan JSON file and return risk assessment.

    Args:
        plan_path: Absolute or relative path to the Terraform plan JSON file.

    Returns:
        Dictionary containing risk level, approval requirement, resource
        counts, and detailed resource lists.

    Raises:
        FileNotFoundError: If the plan file does not exist.
        json.JSONDecodeError: If the plan file is not valid JSON.
        KeyError: If the plan JSON is missing expected fields.
    """
    # Load and validate the plan JSON
    with open(plan_path, "r", encoding="utf-8") as f:
        plan = json.load(f)

    # Initialize counters
    add_count = 0
    change_count = 0
    destroy_count = 0
    replace_count = 0

    # Initialize detail lists
    resources_added = []
    resources_changed = []
    resources_destroyed = []
    resources_replaced = []

    # Extract resource changes from the plan
    resource_changes = plan.get("resource_changes", [])

    for resource in resource_changes:
        # Skip data sources -- they are read-only lookups, not managed resources
        if resource.get("mode", "") == "data":
            continue

        change = resource.get("change", {})
        actions = change.get("actions", [])
        address = resource.get("address", "unknown")
        resource_type = resource.get("type", "unknown")

        resource_info = {
            "address": address,
            "type": resource_type,
            "actions": actions,
        }

        # Classify the action
        if actions == ["create"]:
            add_count += 1
            resources_added.append(resource_info)
        elif actions == ["update"]:
            change_count += 1
            resources_changed.append(resource_info)
        elif actions == ["delete"]:
            destroy_count += 1
            resources_destroyed.append(resource_info)
        elif actions == ["delete", "create"] or actions == ["create", "delete"]:
            # Replacement (destroy then recreate, or create-before-destroy)
            replace_count += 1
            resources_replaced.append(resource_info)
        elif "delete" in actions:
            # Any other action set containing delete is destructive
            destroy_count += 1
            resources_destroyed.append(resource_info)
        elif "update" in actions or "create" in actions:
            # Mixed actions that include update or create but not delete
            change_count += 1
            resources_changed.append(resource_info)
        elif actions == ["no-op"] or actions == ["read"]:
            # No changes -- skip
            continue
        else:
            # Unknown action type -- treat as a change for safety
            change_count += 1
            resources_changed.append(resource_info)

    # Determine risk level
    risk_level = determine_risk_level(
        add_count, change_count, destroy_count, replace_count
    )

    # Determine if approval is required (MEDIUM and HIGH need approval)
    requires_approval = risk_level in ("MEDIUM", "HIGH")

    result = {
        "risk_level": risk_level,
        "requires_approval": requires_approval,
        "add": add_count,
        "change": change_count,
        "destroy": destroy_count,
        "replace": replace_count,
        "details": {
            "resources_added": resources_added,
            "resources_changed": resources_changed,
            "resources_destroyed": resources_destroyed,
            "resources_replaced": resources_replaced,
        },
    }

    return result


def determine_risk_level(
    add: int, change: int, destroy: int, replace: int
) -> str:
    """Determine the risk level based on resource change counts.

    Args:
        add: Number of resources being added.
        change: Number of resources being changed/updated.
        destroy: Number of resources being destroyed.
        replace: Number of resources being replaced (destroy + recreate).

    Returns:
        Risk level string: "LOW", "MEDIUM", or "HIGH".
    """
    # HIGH: Any deletions or replacements
    if destroy > 0 or replace > 0:
        return "HIGH"

    # MEDIUM: Changes/updates present but no deletions
    if change > 0:
        return "MEDIUM"

    # LOW: Only additions (or no changes at all)
    return "LOW"


def set_github_output(result: dict) -> None:
    """Write key values to GITHUB_OUTPUT for use in subsequent workflow steps.

    Each key-value pair is written as a separate line in the format
    expected by GitHub Actions (key=value).

    Args:
        result: The parsed plan result dictionary.
    """
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a", encoding="utf-8") as f:
            f.write(f"risk_level={result['risk_level']}\n")
            f.write(f"requires_approval={str(result['requires_approval']).lower()}\n")
            f.write(f"add={result['add']}\n")
            f.write(f"change={result['change']}\n")
            f.write(f"destroy={result['destroy']}\n")
            f.write(f"replace={result['replace']}\n")
            # Write the full JSON result as a single-line value
            f.write(f"result={json.dumps(result, separators=(',', ':'))}\n")


def main() -> None:
    """Entry point: parse command-line arguments and run the plan parser."""
    if len(sys.argv) != 2:
        print(
            f"Usage: {sys.argv[0]} <path-to-tfplan.json>",
            file=sys.stderr,
        )
        sys.exit(1)

    plan_path = sys.argv[1]

    if not os.path.isfile(plan_path):
        print(f"Error: Plan file not found: {plan_path}", file=sys.stderr)
        sys.exit(1)

    try:
        result = parse_plan(plan_path)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in plan file: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyError as e:
        print(f"Error: Missing expected field in plan JSON: {e}", file=sys.stderr)
        sys.exit(1)

    # Print the result as formatted JSON to stdout
    print(json.dumps(result, indent=2))

    # Set GitHub Actions output variables if running in CI
    set_github_output(result)

    # Exit with non-zero status if risk level is HIGH (for conditional logic)
    # Note: This does NOT fail the workflow -- callers decide how to handle it
    if result["risk_level"] == "HIGH":
        print(
            "\nWARNING: HIGH risk changes detected. Manual approval recommended.",
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
