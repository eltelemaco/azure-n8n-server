#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# update-status-line.sh - Update Status Line from GitHub Actions
# -----------------------------------------------------------------------------
# Purpose: Updates the Claude status line with workflow execution information.
# Used by GitHub Actions workflows to provide status updates throughout execution.
#
# Usage:
#   ./update-status-line.sh <message> [level]
#
# Arguments:
#   message - Status message to display
#   level   - Optional status level: info, success, warning, error (default: info)
#
# Environment variables:
#   GITHUB_RUN_ID      - GitHub Actions run ID
#   GITHUB_WORKFLOW    - Workflow name
#   GITHUB_JOB         - Job name
#   GITHUB_SERVER_URL  - GitHub server URL
#   GITHUB_REPOSITORY  - Repository name
# -----------------------------------------------------------------------------

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
STATUS_MESSAGE="${1:-}"
STATUS_LEVEL="${2:-info}"

STATUS_LINE_SCRIPT=".claude/status_lines/status_line.py"

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
if [ -z "${STATUS_MESSAGE}" ]; then
    echo "Error: Status message is required" >&2
    echo "Usage: $0 <message> [level]" >&2
    exit 1
fi

if [ ! -f "${STATUS_LINE_SCRIPT}" ]; then
    echo "Warning: Status line script not found: ${STATUS_LINE_SCRIPT}" >&2
    echo "Skipping status line update"
    exit 0
fi

# ---------------------------------------------------------------------------
# Build status line content
# ---------------------------------------------------------------------------
# Extract workflow context from environment variables
WORKFLOW_RUN_ID="${GITHUB_RUN_ID:-unknown}"
WORKFLOW_NAME="${GITHUB_WORKFLOW:-terraform-hooks-integration}"
JOB_NAME="${GITHUB_JOB:-unknown}"
SERVER_URL="${GITHUB_SERVER_URL:-https://github.com}"
REPOSITORY="${GITHUB_REPOSITORY:-unknown/unknown}"

# Build status line text with workflow context
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
WORKFLOW_LINK="${SERVER_URL}/${REPOSITORY}/actions/runs/${WORKFLOW_RUN_ID}"

STATUS_TEXT="[${WORKFLOW_NAME}] ${JOB_NAME}: ${STATUS_MESSAGE} | Run: #${WORKFLOW_RUN_ID} | ${TIMESTAMP}"

# ---------------------------------------------------------------------------
# Update status line
# ---------------------------------------------------------------------------
echo "::group::Updating status line"
echo "Message: ${STATUS_MESSAGE}"
echo "Level: ${STATUS_LEVEL}"
echo "Workflow: ${WORKFLOW_NAME}"
echo "Job: ${JOB_NAME}"
echo "Run ID: ${WORKFLOW_RUN_ID}"

# Execute status line update script
# The script may expect different input formats, so we'll try a few approaches
if command -v python3 &> /dev/null; then
    # Try direct Python execution
    if python3 "${STATUS_LINE_SCRIPT}" --message "${STATUS_TEXT}" --level "${STATUS_LEVEL}" 2>&1; then
        echo "Status line updated successfully"
    else
        echo "Warning: Status line update may have failed (non-blocking)" >&2
    fi
elif command -v uv &> /dev/null; then
    # Try with uv run
    if uv run "${STATUS_LINE_SCRIPT}" --message "${STATUS_TEXT}" --level "${STATUS_LEVEL}" 2>&1; then
        echo "Status line updated successfully"
    else
        echo "Warning: Status line update may have failed (non-blocking)" >&2
    fi
else
    echo "Warning: Neither python3 nor uv found, skipping status line update" >&2
fi

echo "::endgroup::"

# Always exit successfully (status line updates are non-blocking)
exit 0
