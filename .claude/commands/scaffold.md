---
allowed-tools: Write, Read
description: Generate a tailored CLAUDE.md for a destination project based on stack and conventions
---

# Scaffold

Generate a complete, production-ready `CLAUDE.md` file tailored to a destination project based on the provided description.

## Input

The `$ARGUMENTS` parameter describes the destination project. Examples:

- "Azure Terraform IaC project with modular structure"
- "Python FastAPI REST API with PostgreSQL"
- "Next.js 14 app router with Prisma and tRPC"
- "Rust CLI tool with clap"

## Analysis Steps

1. **Parse the project description** from `$ARGUMENTS` to identify:
   - **Language**: Python, TypeScript, Rust, Go, etc.
   - **Framework**: FastAPI, Next.js, Django, Express, etc.
   - **Key Technologies**: PostgreSQL, Prisma, Terraform, etc.
   - **Project Type**: REST API, CLI tool, IaC, web app, etc.
   - **Architecture Pattern**: Modular, monolithic, microservices, etc.

2. **Infer project-specific conventions**:
   - **Build command**: `npm run build`, `cargo build`, `terraform plan`, etc.
   - **Test command**: `pytest`, `npm test`, `cargo test`, etc.
   - **Lint command**: `ruff check`, `eslint`, `terraform fmt`, etc.
   - **Package manager**: npm, uv, cargo, go mod, etc.
   - **Directory structure**: Standard for the stack (e.g., Terraform modules, FastAPI routers)
   - **Protected paths**: `.tfstate`, `.env`, `migrations/`, `node_modules/`, etc.

3. **Determine appropriate agents**:
   - **builder**: Always included (implementation)
   - **validator**: Always included (verification)
   - **test-runner**: Always included (quality checks)
   - **pre-flight**: Always included (environment validation)
   - **Stack-specific agents**: e.g., terraform-validator, api-tester, etc. (optional)

4. **Define guardrails and constraints**:
   - File/directory patterns to protect
   - Commands that should require permission
   - Validation rules specific to the stack

## Output

Write a complete `CLAUDE.md` file to the current working directory with the following structure:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[2-3 sentence description of what this project does]

## Project Specifics

| Key              | Value                          |
|------------------|--------------------------------|
| **Name**         | [Inferred from description]    |
| **Language**     | [Detected language]            |
| **Framework**    | [Detected framework]           |
| **Stack**        | [Key technologies]             |
| **Build**        | `[build command]`              |
| **Test**         | `[test command]`               |
| **Lint**         | `[lint command]`               |
| **Pkg Manager**  | [Package manager]              |

## Architecture

[Describe the architecture pattern and key conventions for this stack]

### Directory Structure

```text
[Stack-appropriate directory tree]
```

### Key Conventions

[Stack-specific conventions, e.g.:]

- Terraform: Module structure, variable naming, state management
- FastAPI: Router organization, dependency injection, Pydantic models
- Next.js: App router patterns, server/client components, API routes
- Rust: Crate structure, error handling patterns, trait usage

## Orchestration Protocol

This project uses the **agentic orchestration framework** with specialized agents for workflow management.

### Agent Definitions

#### Builder Agent

- **Purpose**: Implements features, writes code, creates files
- **Model**: Claude Opus 4.5
- **Permissions**: Read, Write, Edit, Bash
- **When to use**: For all implementation tasks

#### Validator Agent

- **Purpose**: Verifies task completion and correctness
- **Model**: Claude Opus 4.5
- **Permissions**: Read, Bash (read-only, no Write/Edit)
- **When to use**: After builder completes work, to verify requirements met

#### Test-Runner Agent

- **Purpose**: Runs tests, linting, type checking, and quality validation
- **Model**: Claude Sonnet 4.5
- **Permissions**: Read, Bash (read-only, no Write/Edit)
- **When to use**: Before committing code, to ensure quality standards

#### Pre-Flight Agent

- **Purpose**: Validates environment readiness before starting work
- **Model**: Claude Haiku 4.5
- **Permissions**: Read, Bash (read-only, no Write/Edit)
- **When to use**: At session start or before major changes

[Add stack-specific agents if relevant]

### Workflow Pattern

1. **Pre-Flight** → Validate environment (tools installed, dependencies ready)
2. **Plan** → Create implementation plan (use `/plan` command)
3. **Build** → Implement via builder agent (use `/build` command)
4. **Validate** → Verify completion via validator agent
5. **Test** → Run quality checks via test-runner agent
6. **Review** → Human review and approval
7. **Commit** → Git commit when all checks pass

## Commands

This project includes custom slash commands:

- `/prime` - Load project context for new sessions
- `/plan` - Create implementation plans
- `/build` - Execute builder agent to implement features
- `/question` - Answer questions about project structure

## Hook System

The orchestration framework uses lifecycle hooks for:

- **PreToolUse**: Log tool calls before execution
- **PostToolUse**: Log results, trigger validators on Write/Edit (e.g., [stack-specific validators])
- **PostToolUseFailure**: Log errors for debugging
- **PermissionRequest**: Auto-allow safe operations (e.g., `mkdir`, `[package manager commands]`)
- **SessionStart/End**: Session lifecycle management
- **SubagentStart/Stop**: Agent lifecycle tracking

All hooks are Python scripts executed via `uv run --script` with PEP 723 inline dependencies.

## Guardrails

### Protected Paths

Do NOT modify or delete these paths without explicit permission:

[Stack-specific protected paths, e.g.:]

- Terraform: `*.tfstate`, `*.tfstate.backup`, `.terraform/`, `.terraform.lock.hcl`
- Python: `.env`, `venv/`, `__pycache__/`, `*.pyc`
- Node.js: `node_modules/`, `.env`, `.env.local`, `package-lock.json`
- Rust: `target/`, `Cargo.lock` (in libraries)
- General: `.git/`, `logs/`, `*.log`

### Required Permissions

These operations require explicit user permission:

[Stack-specific dangerous operations, e.g.:]

- Terraform: `terraform destroy`, `terraform apply` (without plan review)
- Database: Migrations, schema changes, data deletion
- Dependencies: Major version upgrades, removing dependencies
- Git: Force push, rebasing published branches, destructive operations

### Validation Rules

[Stack-specific validation rules, e.g.:]

- Terraform: Run `terraform fmt` and `terraform validate` after changes
- Python: Run `ruff check` and type checking after code changes
- Node.js: Run `eslint` and `tsc --noEmit` before commits
- Rust: Run `cargo fmt` and `cargo clippy` before commits

## Development Workflow

### Initial Setup

```bash
[Stack-specific setup commands, e.g.:]
# Clone repository
git clone <repo-url>
cd <repo-name>

# Install dependencies
[package manager install command]

# Setup environment
[environment setup commands]

# Verify setup
[verification commands]
```

### Daily Workflow

```bash
# Start session - load context
/prime

# Before making changes - validate environment
[Run pre-flight checks]

# Make changes
[Implementation workflow]

# Run quality checks
[Test/lint commands]

# Commit changes
git add <files>
git commit -m "descriptive message"
git push
```

### Testing

```bash
# Run all tests
[test command]

# Run specific test
[specific test command syntax]

# Run with coverage
[coverage command if applicable]
```

### Linting and Formatting

```bash
# Check code style
[lint command]

# Auto-fix issues
[lint fix command]

# Format code
[format command if different from lint]
```

## Stack-Specific Guidelines

[Include detailed, stack-specific guidance here]

### [Technology 1]

[Key conventions, best practices, common patterns]

### [Technology 2]

[Key conventions, best practices, common patterns]

## Troubleshooting

### Common Issues

[Stack-specific common issues and solutions, e.g.:]

**[Issue 1]**

- Symptom: [Description]
- Solution: [Fix]

**[Issue 2]**

- Symptom: [Description]
- Solution: [Fix]

## Environment Requirements

### Required

- [Language/runtime and version]
- [Package manager and version]
- [Key tools, e.g., terraform, docker, etc.]

### Optional

- [Optional tools and their purposes]

### Environment Variables

- `[VAR_NAME]` - [Description]
- `[VAR_NAME_2]` - [Description]

## Configuration Files

[List and describe key configuration files for this stack, e.g.:]

- `[config file]` - [Purpose]
- `.claude/settings.local.json` - Orchestration hooks and permissions
- `.claude/CLAUDE.md` - This file

## Memory and Context

This project uses three-tier memory:

1. **Auto Memory**: Claude's automatic session memory
2. **Agent Memory**: Agent-specific persistent memory in `.claude/agent-memory/`
3. **Project Memory**: Shared instructions in `CLAUDE.md` and `.claude/CLAUDE.md`

Use `/prime` at session start to load full project context.

## Special Notes

[Stack-specific special notes, warnings, or critical information]

---

## Generated by agentic-orchestration framework

```text

## Implementation Instructions

1. Analyze `$ARGUMENTS` to extract project details
2. Infer all project-specific values (language, framework, commands, etc.)
3. Generate the complete `CLAUDE.md` with all sections filled in
4. Replace ALL placeholders with actual, inferred values:
   - `[Inferred from description]` → Actual project name
   - `[Detected language]` → Actual language (Python, TypeScript, etc.)
   - `[build command]` → Actual build command for the stack
   - `[Stack-specific ...]` → Actual stack-specific content
5. Ensure the generated `CLAUDE.md` is:
   - Complete and self-contained
   - Free of placeholders and TODOs
   - Specific to the project's stack
   - Production-ready for immediate use
6. Write the file to `./CLAUDE.md` in the current directory

## Validation

After generating the file, verify:
- No `[placeholder text]` remains
- All sections are filled with specific, actionable content
- Stack-specific conventions are accurate
- Commands are correct for the detected stack
- Protected paths match the technology
- The file is immediately usable without modification

## Example Invocations

`/scaffold Azure Terraform IaC project with modular structure`
→ Generates CLAUDE.md with Terraform-specific commands, module conventions, state management guidelines

`/scaffold Python FastAPI REST API with PostgreSQL and authentication`
→ Generates CLAUDE.md with FastAPI patterns, Pydantic models, database migrations, auth workflows

`/scaffold Next.js 14 app router with Prisma, tRPC, and Tailwind`
→ Generates CLAUDE.md with App Router patterns, server/client components, API routes, Prisma schema management

`/scaffold Rust CLI tool with clap for command parsing`
→ Generates CLAUDE.md with Rust conventions, error handling patterns, Cargo commands, clippy rules
