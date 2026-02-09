# Plan: GitHub Actions Workflow with Claude Hooks Integration - First Iteration

## Task Description

Implement the first iteration of a GitHub Actions workflow that integrates Claude hooks into the CI/CD pipeline. This workflow will execute Terraform operations in the `infra/environments/dev` directory while running Claude hooks at appropriate lifecycle points (session start, pre-tool use, post-tool use, session end). Each hook execution will have dedicated builder and validator agent pairs to ensure proper execution and validation. The workflow will also include status line updates, pre-flight validation, and documentation updates.

## Objective

Create a GitHub Actions workflow file (`.github/workflows/terraform-hooks-integration.yml`) that:

1. **Integrates Claude Hooks**: Executes hooks at workflow lifecycle points (start, before steps, after steps, end)
2. **Builder/Validator Pairs**: Each hook execution has a dedicated builder to run the hook and a validator to verify execution
3. **Pre-Flight Validation**: Validates environment readiness before workflow execution
4. **Status Line Updates**: Updates status lines throughout workflow execution
5. **Terraform Operations**: Performs Terraform format, validate, plan, and apply operations in `infra/environments/dev`
6. **Documentation Updates**: Updates README.md with workflow execution results

## Problem Statement

Currently, the existing GitHub Actions workflows (terraform-pr-checks.yml and terraform-deploy.yml) do not integrate with the Claude hooks system. The hooks provide valuable capabilities such as:

- Session lifecycle tracking (session_start, session_end)
- Tool usage monitoring (pre_tool_use, post_tool_use)
- Permission requests and notifications
- Validation and logging

Integrating hooks into the CI/CD pipeline will provide:
- Better observability of workflow execution
- Consistent logging and tracking across local and CI environments
- Validation and security checks via hooks
- Status updates and notifications

Without this integration, the hooks system remains isolated to local development, missing opportunities for CI/CD integration and centralized logging.

## Solution Approach

### Workflow Structure

1. **Pre-Flight Phase**: Environment validation before any operations
2. **Session Start Hook**: Initialize session tracking
3. **Terraform Operations**: Format, validate, plan, apply (each with pre/post hooks)
4. **Session End Hook**: Finalize session tracking
5. **Documentation Update**: Update README with results

### Hook Integration Pattern

Each hook execution follows this pattern:
1. **Builder Agent**: Executes the hook script with appropriate JSON input
2. **Validator Agent**: Verifies hook execution succeeded and output is valid
3. **Status Update**: Updates status line with hook execution result

### Hook Execution Points

- **session_start**: At workflow start (after pre-flight)
- **pre_tool_use**: Before each Terraform command (format, validate, plan, apply)
- **post_tool_use**: After each Terraform command succeeds
- **post_tool_use_failure**: After each Terraform command fails
- **session_end**: At workflow end (before documentation update)

## Relevant Files

### Existing Files to Reference

- `.github/workflows/terraform-pr-checks.yml` - Reference for workflow structure and job patterns
- `.github/workflows/terraform-deploy.yml` - Reference for deployment workflow patterns
- `.github/actions/setup-terraform/action.yml` - Composite action for Terraform setup
- `.claude/hooks/session_start.py` - Session start hook implementation
- `.claude/hooks/pre_tool_use.py` - Pre-tool use hook implementation
- `.claude/hooks/post_tool_use.py` - Post-tool use hook implementation
- `.claude/hooks/post_tool_use_failure.py` - Post-tool use failure hook implementation
- `.claude/hooks/session_end.py` - Session end hook implementation
- `.claude/agents/team/builder.md` - Builder agent definition
- `.claude/agents/team/validator.md` - Validator agent definition
- `.claude/agents/team/pre-flight.md` - Pre-flight agent definition
- `.claude/status_lines/status_line.py` - Status line update utility
- `README.md` - Documentation file to update

### New Files to Create

- `.github/workflows/terraform-hooks-integration.yml` - Main workflow file integrating hooks
- `.github/scripts/run-hook.sh` - Helper script to execute hooks with JSON input/output handling
- `.github/scripts/update-status-line.sh` - Helper script to update status lines from workflow

## Implementation Phases

### Phase 1: Foundation

**Duration**: Sequential execution
**Focus**: Create helper scripts and workflow structure

1. Create helper script for hook execution (`run-hook.sh`)
2. Create helper script for status line updates (`update-status-line.sh`)
3. Create workflow file structure with basic job definitions
4. Set up environment variables and working directory configuration

### Phase 2: Core Implementation

**Duration**: Sequential execution with parallel hook execution where possible
**Focus**: Implement hook integration and Terraform operations

1. Implement pre-flight validation job
2. Implement session_start hook execution (builder + validator)
3. Implement Terraform format operation with pre/post hooks
4. Implement Terraform validate operation with pre/post hooks
5. Implement Terraform plan operation with pre/post hooks
6. Implement Terraform apply operation with pre/post hooks (conditional)
7. Implement session_end hook execution (builder + validator)

### Phase 3: Integration & Polish

**Duration**: Sequential validation and documentation
**Focus**: Status updates, documentation, and final validation

1. Add status line updates throughout workflow
2. Implement documentation update job
3. Add comprehensive error handling and failure recovery
4. Validate workflow syntax and test execution
5. Update README.md with workflow documentation

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.
  - This is critical. You're job is to act as a high level director of the team, not a builder.
  - You're role is to validate all work is going well and make sure the team is on track to complete the plan.
  - You'll orchestrate this by using the Task* Tools to manage coordination between the team members.
  - Communication is paramount. You'll use the Task* Tools to communicate with the team members and ensure they're on track to complete the plan.
- Take note of the session id of each team member. This is how you'll reference them.

### Team Members

- **Pre-Flight Validator**
  - Name: preflight-env-validator
  - Role: Validate environment readiness before workflow execution (tools, credentials, git status)
  - Agent Type: pre-flight
  - Resume: true

- **Session Start Hook Builder**
  - Name: builder-session-start-hook
  - Role: Execute session_start.py hook with workflow context JSON
  - Agent Type: builder
  - Resume: true

- **Session Start Hook Validator**
  - Name: validator-session-start-hook
  - Role: Verify session_start hook executed successfully and logged properly
  - Agent Type: validator
  - Resume: true

- **Pre-Tool Use Hook Builder**
  - Name: builder-pre-tool-use-hook
  - Role: Execute pre_tool_use.py hook before Terraform commands
  - Agent Type: builder
  - Resume: true

- **Pre-Tool Use Hook Validator**
  - Name: validator-pre-tool-use-hook
  - Role: Verify pre_tool_use hook executed and didn't block the operation
  - Agent Type: validator
  - Resume: true

- **Post-Tool Use Hook Builder**
  - Name: builder-post-tool-use-hook
  - Role: Execute post_tool_use.py hook after successful Terraform commands
  - Agent Type: builder
  - Resume: true

- **Post-Tool Use Hook Validator**
  - Name: validator-post-tool-use-hook
  - Role: Verify post_tool_use hook executed and logged properly
  - Agent Type: validator
  - Resume: true

- **Post-Tool Use Failure Hook Builder**
  - Name: builder-post-tool-use-failure-hook
  - Role: Execute post_tool_use_failure.py hook after failed Terraform commands
  - Agent Type: builder
  - Resume: true

- **Post-Tool Use Failure Hook Validator**
  - Name: validator-post-tool-use-failure-hook
  - Role: Verify post_tool_use_failure hook executed and logged error properly
  - Agent Type: validator
  - Resume: true

- **Session End Hook Builder**
  - Name: builder-session-end-hook
  - Role: Execute session_end.py hook at workflow completion
  - Agent Type: builder
  - Resume: true

- **Session End Hook Validator**
  - Name: validator-session-end-hook
  - Role: Verify session_end hook executed successfully
  - Agent Type: validator
  - Resume: true

- **Status Line Updater**
  - Name: status-line-updater
  - Role: Update status lines throughout workflow execution
  - Agent Type: general-purpose
  - Resume: true

- **Validation and Documentation Agent**
  - Name: validation-documentation-agent
  - Role: Validate workflow execution and update documentation
  - Agent Type: general-purpose
  - Resume: true

- **Documentation Agent**
  - Name: documentation-agent
  - Role: Update README.md with workflow execution results and status
  - Agent Type: general-purpose
  - Resume: true

## Step by Step Tasks

- IMPORTANT: Execute every step in order, top to bottom. Each task maps directly to a `TaskCreate` call.
- Before you start, run `TaskCreate` to create the initial task list that all team members can see and execute.

### 1. Pre-Flight Environment Validation

- **Task ID**: preflight-env-check
- **Depends On**: none
- **Assigned To**: preflight-env-validator
- **Agent Type**: pre-flight
- **Parallel**: false
- Verify required tools are installed (terraform, python, uv, git)
- Check GitHub Actions environment variables are set (GITHUB_WORKSPACE, GITHUB_RUN_ID, etc.)
- Verify working directory `infra/environments/dev` exists
- Check that hook scripts exist and are executable
- Validate HCP Terraform token is available (if required)
- Report environment readiness status

### 2. Create Hook Execution Helper Script

- **Task ID**: create-run-hook-script
- **Depends On**: preflight-env-check
- **Assigned To**: builder-session-start-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `.github/scripts/run-hook.sh` script
- Script should accept hook name, JSON input file path, and output file path
- Script should execute hook using `uv run` with proper JSON input piping
- Script should handle exit codes (0 = success, 2 = blocked, 1 = error)
- Script should capture hook output JSON if provided
- Make script executable (`chmod +x`)

### 3. Create Status Line Update Helper Script

- **Task ID**: create-status-line-script
- **Depends On**: create-run-hook-script
- **Assigned To**: status-line-updater
- **Agent Type**: general-purpose
- **Parallel**: false
- Create `.github/scripts/update-status-line.sh` script
- Script should accept status message and optional status level (info, success, warning, error)
- Script should update status line using Python status_line.py utility
- Script should handle GitHub Actions environment (GITHUB_RUN_ID, etc.)
- Make script executable (`chmod +x`)

### 4. Create Workflow File Structure

- **Task ID**: create-workflow-structure
- **Depends On**: create-status-line-script
- **Assigned To**: builder-session-start-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `.github/workflows/terraform-hooks-integration.yml`
- Define workflow name, triggers (on push to main, manual dispatch)
- Set up environment variables (TF_WORKING_DIR: infra/environments/dev)
- Define concurrency controls
- Set up permissions (contents: read, pull-requests: write)
- Create job structure skeleton with dependencies

### 5. Implement Pre-Flight Validation Job

- **Task ID**: implement-preflight-job
- **Depends On**: create-workflow-structure
- **Assigned To**: builder-session-start-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `preflight-validation` job
- Use pre-flight agent to validate environment
- Check tools, credentials, working directory
- Output validation status for downstream jobs
- Fail workflow if critical checks fail

### 6. Implement Session Start Hook Execution

- **Task ID**: implement-session-start-hook
- **Depends On**: implement-preflight-job
- **Assigned To**: builder-session-start-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `session-start-hook-builder` job
- Generate session_start JSON input with workflow context (run_id, workflow, actor, etc.)
- Execute session_start.py hook using run-hook.sh script
- Capture hook output and log files
- Upload hook logs as artifacts

### 7. Validate Session Start Hook Execution

- **Task ID**: validate-session-start-hook
- **Depends On**: implement-session-start-hook
- **Assigned To**: validator-session-start-hook
- **Agent Type**: validator
- **Parallel**: false
- Create `session-start-hook-validator` job
- Verify session_start hook executed successfully (exit code 0)
- Check that log file was created in `.claude/logs/session_start.json`
- Validate log file contains expected workflow context
- Report validation status

### 8. Implement Terraform Format with Hooks

- **Task ID**: implement-terraform-format-hooks
- **Depends On**: validate-session-start-hook
- **Assigned To**: builder-pre-tool-use-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `terraform-format-with-hooks` job
- Execute pre_tool_use hook before terraform fmt command
- Run `terraform fmt -check -recursive` in working directory
- Execute post_tool_use hook after successful format check
- Execute post_tool_use_failure hook if format check fails
- Update status line with format check result

### 9. Validate Terraform Format Hooks

- **Task ID**: validate-terraform-format-hooks
- **Depends On**: implement-terraform-format-hooks
- **Assigned To**: validator-pre-tool-use-hook
- **Agent Type**: validator
- **Parallel**: false
- Verify pre_tool_use hook executed before terraform fmt
- Verify post_tool_use hook executed after format check
- Check hook logs contain terraform fmt command details
- Validate hook execution didn't block the operation

### 10. Implement Terraform Validate with Hooks

- **Task ID**: implement-terraform-validate-hooks
- **Depends On**: validate-terraform-format-hooks
- **Assigned To**: builder-pre-tool-use-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `terraform-validate-with-hooks` job
- Execute pre_tool_use hook before terraform validate command
- Run `terraform validate` in working directory
- Execute post_tool_use hook after successful validation
- Execute post_tool_use_failure hook if validation fails
- Update status line with validation result

### 11. Validate Terraform Validate Hooks

- **Task ID**: validate-terraform-validate-hooks
- **Depends On**: implement-terraform-validate-hooks
- **Assigned To**: validator-pre-tool-use-hook
- **Agent Type**: validator
- **Parallel**: false
- Verify pre_tool_use hook executed before terraform validate
- Verify post_tool_use hook executed after validation
- Check hook logs contain terraform validate command details
- Validate hook execution didn't block the operation

### 12. Implement Terraform Plan with Hooks

- **Task ID**: implement-terraform-plan-hooks
- **Depends On**: validate-terraform-validate-hooks
- **Assigned To**: builder-pre-tool-use-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `terraform-plan-with-hooks` job
- Execute pre_tool_use hook before terraform plan command
- Run `terraform plan -out=tfplan.binary` in working directory
- Execute post_tool_use hook after successful plan
- Execute post_tool_use_failure hook if plan fails
- Convert plan to JSON for downstream jobs
- Upload plan artifacts
- Update status line with plan result

### 13. Validate Terraform Plan Hooks

- **Task ID**: validate-terraform-plan-hooks
- **Depends On**: implement-terraform-plan-hooks
- **Assigned To**: validator-pre-tool-use-hook
- **Agent Type**: validator
- **Parallel**: false
- Verify pre_tool_use hook executed before terraform plan
- Verify post_tool_use hook executed after plan
- Check hook logs contain terraform plan command details
- Validate plan artifacts were created and uploaded

### 14. Implement Terraform Apply with Hooks (Conditional)

- **Task ID**: implement-terraform-apply-hooks
- **Depends On**: validate-terraform-plan-hooks
- **Assigned To**: builder-pre-tool-use-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `terraform-apply-with-hooks` job (conditional on plan success and manual approval)
- Execute pre_tool_use hook before terraform apply command
- Run `terraform apply tfplan.binary` in working directory
- Execute post_tool_use hook after successful apply
- Execute post_tool_use_failure hook if apply fails
- Capture terraform outputs
- Upload outputs as artifacts
- Update status line with apply result

### 15. Validate Terraform Apply Hooks

- **Task ID**: validate-terraform-apply-hooks
- **Depends On**: implement-terraform-apply-hooks
- **Assigned To**: validator-post-tool-use-hook
- **Agent Type**: validator
- **Parallel**: false
- Verify pre_tool_use hook executed before terraform apply
- Verify post_tool_use hook executed after apply
- Check hook logs contain terraform apply command details
- Validate terraform outputs were captured

### 16. Implement Session End Hook Execution

- **Task ID**: implement-session-end-hook
- **Depends On**: validate-terraform-apply-hooks
- **Assigned To**: builder-session-end-hook
- **Agent Type**: builder
- **Parallel**: false
- Create `session-end-hook-builder` job
- Generate session_end JSON input with workflow summary (status, duration, steps completed)
- Execute session_end.py hook using run-hook.sh script
- Capture hook output and log files
- Upload hook logs as artifacts

### 17. Validate Session End Hook Execution

- **Task ID**: validate-session-end-hook
- **Depends On**: implement-session-end-hook
- **Assigned To**: validator-session-end-hook
- **Agent Type**: validator
- **Parallel**: false
- Verify session_end hook executed successfully (exit code 0)
- Check that log file was created in `.claude/logs/session_end.json`
- Validate log file contains expected workflow summary
- Report validation status

### 18. Add Status Line Updates Throughout Workflow

- **Task ID**: add-status-line-updates
- **Depends On**: validate-session-end-hook
- **Assigned To**: status-line-updater
- **Agent Type**: general-purpose
- **Parallel**: false
- Add status line updates at key workflow points:
  - Workflow start
  - After pre-flight validation
  - After each Terraform operation (format, validate, plan, apply)
  - After hook executions
  - Workflow completion
- Use update-status-line.sh script for consistency
- Include workflow run ID, current step, and status in updates

### 19. Implement Documentation Update Job

- **Task ID**: implement-documentation-update
- **Depends On**: add-status-line-updates
- **Assigned To**: documentation-agent
- **Agent Type**: general-purpose
- **Parallel**: false
- Create `documentation-update` job
- Extract workflow execution summary (status, duration, steps completed)
- Extract Terraform operation results (format, validate, plan, apply status)
- Extract hook execution summary (hooks run, hooks succeeded, hooks failed)
- Update README.md with workflow execution status section
- Commit changes with appropriate commit message
- Push changes to repository

### 20. Final Validation and Testing

- **Task ID**: final-validation-testing
- **Depends On**: implement-documentation-update
- **Assigned To**: validation-documentation-agent
- **Agent Type**: general-purpose
- **Parallel**: false
- Validate workflow YAML syntax using `yamllint` or similar
- Verify all jobs have proper dependencies
- Check that all hook executions have builder/validator pairs
- Verify status line updates are present at key points
- Test workflow can be triggered manually
- Verify documentation update job has proper permissions
- Generate comprehensive validation report

## Acceptance Criteria

1. **Workflow File Created**
   - [ ] `.github/workflows/terraform-hooks-integration.yml` exists
   - [ ] Workflow has proper name, triggers, and permissions
   - [ ] Working directory is set to `infra/environments/dev`

2. **Helper Scripts Created**
   - [ ] `.github/scripts/run-hook.sh` exists and is executable
   - [ ] `.github/scripts/update-status-line.sh` exists and is executable
   - [ ] Scripts handle JSON input/output correctly
   - [ ] Scripts handle error cases gracefully

3. **Pre-Flight Validation**
   - [ ] Pre-flight job validates environment before workflow execution
   - [ ] Job fails if critical checks fail
   - [ ] Job outputs validation status for downstream jobs

4. **Hook Integration**
   - [ ] session_start hook executes at workflow start
   - [ ] pre_tool_use hook executes before each Terraform command
   - [ ] post_tool_use hook executes after successful Terraform commands
   - [ ] post_tool_use_failure hook executes after failed Terraform commands
   - [ ] session_end hook executes at workflow end
   - [ ] Each hook execution has builder and validator jobs

5. **Terraform Operations**
   - [ ] Terraform format check runs with hooks
   - [ ] Terraform validate runs with hooks
   - [ ] Terraform plan runs with hooks
   - [ ] Terraform apply runs with hooks (conditional)
   - [ ] All operations use working directory `infra/environments/dev`

6. **Status Line Updates**
   - [ ] Status lines updated at workflow start
   - [ ] Status lines updated after pre-flight validation
   - [ ] Status lines updated after each Terraform operation
   - [ ] Status lines updated after hook executions
   - [ ] Status lines updated at workflow completion

7. **Documentation Updates**
   - [ ] README.md updated with workflow execution status
   - [ ] Documentation includes workflow run ID, status, and summary
   - [ ] Changes committed and pushed to repository

8. **Validation**
   - [ ] All hook executions have corresponding validator jobs
   - [ ] Hook logs are uploaded as artifacts
   - [ ] Workflow syntax is valid
   - [ ] Job dependencies are correct
   - [ ] Error handling is comprehensive

## Validation Commands

Execute these commands to validate the task is complete:

```bash
# Verify workflow file exists and is valid YAML
yamllint .github/workflows/terraform-hooks-integration.yml

# Verify helper scripts exist and are executable
test -x .github/scripts/run-hook.sh && echo "✅ run-hook.sh executable" || echo "❌ run-hook.sh not executable"
test -x .github/scripts/update-status-line.sh && echo "✅ update-status-line.sh executable" || echo "❌ update-status-line.sh not executable"

# Verify workflow can be parsed by GitHub Actions (syntax check)
# Note: This requires GitHub CLI or manual testing in GitHub UI
gh workflow view terraform-hooks-integration.yml 2>/dev/null || echo "⚠️ Workflow not yet pushed to GitHub"

# Verify hook scripts exist
test -f .claude/hooks/session_start.py && echo "✅ session_start.py exists" || echo "❌ session_start.py missing"
test -f .claude/hooks/pre_tool_use.py && echo "✅ pre_tool_use.py exists" || echo "❌ pre_tool_use.py missing"
test -f .claude/hooks/post_tool_use.py && echo "✅ post_tool_use.py exists" || echo "❌ post_tool_use.py missing"
test -f .claude/hooks/post_tool_use_failure.py && echo "✅ post_tool_use_failure.py exists" || echo "❌ post_tool_use_failure.py missing"
test -f .claude/hooks/session_end.py && echo "✅ session_end.py exists" || echo "❌ session_end.py missing"

# Verify working directory exists
test -d infra/environments/dev && echo "✅ Working directory exists" || echo "❌ Working directory missing"

# Count jobs in workflow (should have pre-flight + session_start builder/validator + terraform ops + session_end builder/validator + documentation)
grep -c "^\s*[a-z-]*:" .github/workflows/terraform-hooks-integration.yml

# Verify all hook executions have validator jobs
grep -c "hook.*validator" .github/workflows/terraform-hooks-integration.yml
```

## Notes

### Hook JSON Input Format

Each hook expects JSON input via stdin. The format varies by hook:

**session_start:**
```json
{
  "session_id": "github-actions-run-123",
  "source": "github-actions",
  "workflow": "terraform-hooks-integration",
  "run_id": "1234567890",
  "actor": "github-actions[bot]",
  "repository": "owner/repo",
  "ref": "refs/heads/main"
}
```

**pre_tool_use / post_tool_use:**
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "terraform fmt -check -recursive"
  },
  "session_id": "github-actions-run-123"
}
```

**session_end:**
```json
{
  "session_id": "github-actions-run-123",
  "status": "success",
  "duration_seconds": 300,
  "steps_completed": 10,
  "steps_failed": 0
}
```

### Hook Exit Codes

- `0`: Success - hook executed successfully
- `1`: Error - hook encountered an error but doesn't block workflow
- `2`: Blocked - hook blocked the operation (workflow should fail)

### Status Line Updates

Status lines should include:
- Workflow run ID
- Current step/job name
- Status (running, success, failure)
- Timestamp
- Link to workflow run (if available)

### Error Handling

- If pre_tool_use hook exits with code 2, the Terraform command should be skipped
- If post_tool_use_failure hook executes, workflow should continue but mark step as failed
- If session_start or session_end hooks fail, log warning but don't fail workflow
- All hook executions should have `continue-on-error: true` except critical validations

### Dependencies

- Requires `uv` to be installed in GitHub Actions runner (Python 3.11+)
- Requires `python-dotenv` package for hooks (handled by uv script dependencies)
- Requires HCP Terraform token for Terraform operations (if using remote state)
- Requires GitHub Actions permissions for workflow execution and PR comments

### Testing Strategy

1. **Manual Testing**: Trigger workflow manually via `workflow_dispatch`
2. **Dry Run**: Test hook execution locally using same JSON input format
3. **Incremental Testing**: Test each hook individually before full integration
4. **Validation**: Verify hook logs are created and contain expected data

### Future Enhancements

- Add notification hooks for workflow completion
- Integrate with GitHub PR comments for hook execution summaries
- Add hook execution metrics and reporting
- Support for custom hooks in workflow
- Parallel hook execution where possible
