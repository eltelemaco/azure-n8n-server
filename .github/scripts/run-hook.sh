#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# run-hook.sh - Execute Claude Hook Script
# -----------------------------------------------------------------------------
# Purpose: Executes a Claude hook script with JSON input and captures output.
# Used by GitHub Actions workflows to integrate hooks into CI/CD pipeline.
#
# Usage:
#   ./run-hook.sh <hook-name> <input-json-file> [output-json-file]
#
# Arguments:
#   hook-name        - Name of the hook script (e.g., session_start, pre_tool_use)
#   input-json-file  - Path to JSON file containing hook input data
#   output-json-file - Optional path to save hook output JSON
#
# Exit codes:
#   0 - Hook executed successfully
#   1 - Hook execution error
#   2 - Hook blocked the operation (should fail workflow)
# -----------------------------------------------------------------------------

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
HOOK_NAME="${1:-}"
INPUT_JSON_FILE="${2:-}"
OUTPUT_JSON_FILE="${3:-}"

HOOKS_DIR=".claude/hooks"
HOOK_SCRIPT="${HOOKS_DIR}/${HOOK_NAME}.py"

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
if [ -z "${HOOK_NAME}" ]; then
    echo "Error: Hook name is required" >&2
    echo "Usage: $0 <hook-name> <input-json-file> [output-json-file]" >&2
    exit 1
fi

if [ -z "${INPUT_JSON_FILE}" ]; then
    echo "Error: Input JSON file is required" >&2
    echo "Usage: $0 <hook-name> <input-json-file> [output-json-file]" >&2
    exit 1
fi

if [ ! -f "${HOOK_SCRIPT}" ]; then
    echo "Error: Hook script not found: ${HOOK_SCRIPT}" >&2
    exit 1
fi

if [ ! -f "${INPUT_JSON_FILE}" ]; then
    echo "Error: Input JSON file not found: ${INPUT_JSON_FILE}" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Execute hook
# ---------------------------------------------------------------------------
echo "::group::Executing hook: ${HOOK_NAME}"
echo "Hook script: ${HOOK_SCRIPT}"
echo "Input file: ${INPUT_JSON_FILE}"

# Execute hook with JSON input from file
# Capture both stdout (hook output JSON) and stderr (hook logs/errors)
if [ -n "${OUTPUT_JSON_FILE}" ]; then
    # Save output to file
    if uv run "${HOOK_SCRIPT}" < "${INPUT_JSON_FILE}" > "${OUTPUT_JSON_FILE}" 2>&1; then
        HOOK_EXIT_CODE=$?
    else
        HOOK_EXIT_CODE=$?
    fi
else
    # Output to stdout
    if uv run "${HOOK_SCRIPT}" < "${INPUT_JSON_FILE}" 2>&1; then
        HOOK_EXIT_CODE=$?
    else
        HOOK_EXIT_CODE=$?
    fi
fi

echo "Hook exit code: ${HOOK_EXIT_CODE}"
echo "::endgroup::"

# ---------------------------------------------------------------------------
# Handle exit codes
# ---------------------------------------------------------------------------
case "${HOOK_EXIT_CODE}" in
    0)
        echo "Hook ${HOOK_NAME} executed successfully"
        exit 0
        ;;
    1)
        echo "Warning: Hook ${HOOK_NAME} encountered an error (non-blocking)" >&2
        exit 1
        ;;
    2)
        echo "Error: Hook ${HOOK_NAME} blocked the operation" >&2
        exit 2
        ;;
    *)
        echo "Warning: Hook ${HOOK_NAME} exited with unexpected code ${HOOK_EXIT_CODE}" >&2
        exit 1
        ;;
esac
