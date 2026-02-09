# Claude Code Agent Configuration

This directory contains the agent orchestration configuration for the aws-n8n-server project.

## 📁 Directory Structure

```text
.claude/
├── agents/
│   ├── team/
│   │   ├── builder.md           # Implementation agent (Opus, Read/Write)
│   │   ├── validator.md         # Validation agent (Opus, Read-Only)
│   │   ├── test-runner.md       # Quality check agent (Sonnet, Read-Only)
│   │   └── pre-flight.md        # Environment validation (Haiku, Read-Only)
│   ├── meta-agent.md            # Agent creation agent (Sonnet)
│   └── work-completion-summary.md  # TTS summary agent (Sonnet)
├── hooks/
│   ├── pre_compact.py           # Pre-compaction hook
│   ├── pre_tool_use.py          # Pre-tool execution hook
│   ├── post_tool_use.py         # Post-tool execution hook
│   ├── post_tool_use_failure.py # Tool failure hook
│   ├── session_start.py         # Session initialization hook
│   ├── session_end.py           # Session cleanup hook
│   ├── subagent_start.py        # Subagent initialization hook
│   ├── subagent_stop.py         # Subagent completion hook
│   ├── user_prompt_submit.py    # User input hook
│   └── validators/
│       ├── ruff_validator.py    # Python linting (Ruff)
│       ├── ty_validator.py      # Type checking (Ty)
│       ├── validate_file_contains.py
│       └── validate_new_file.py
├── hooks/utils/
│   ├── llm/anth.py              # Anthropic API integration
│   └── tts/                     # Text-to-speech utilities
├── commands/                    # Custom slash commands
├── output-styles/               # Response formatting styles
├── status_lines/                # Status line configurations
├── agent-memory/                # Agent persistent memory
├── data/                        # Runtime data and caches
└── settings.json                # Main configuration file

```

## 🤖 Available Agents

### Team Agents (Execution)

#### Builder Agent

**File:** `agents/team/builder.md`
**Model:** claude-opus-4-5-20251101
**Color:** cyan
**Type:** Read/Write
**Description:** Generic engineering agent that executes ONE task at a time

**Use when:**

- Implementing features
- Creating new files
- Modifying existing code
- Running build/deploy commands

**Hooks:**

- PostToolUse (Write|Edit): Runs ruff_validator.py and ty_validator.py

**Example invocation:**

```typescript
Task({
  subagent_type: "builder",
  description: "Implement SSM wrapper",
  prompt: "Create scripts/ssm-deploy-wrapper.sh for SSM deployment"
})
```

#### Validator Agent

**File:** `agents/team/validator.md`
**Model:** claude-opus-4-5-20251101
**Color:** yellow
**Type:** Read-Only
**Description:** Validates task completion against acceptance criteria

**Use when:**

- After builder completes work
- Verifying acceptance criteria
- Running comprehensive test suites
- Generating quality reports

**Disallowed Tools:** Write, Edit, NotebookEdit

**Example invocation:**

```typescript
Task({
  subagent_type: "validator",
  description: "Validate deployment",
  prompt: "Verify that deployment script and GitHub Actions workflow were created correctly"
})
```

#### Test-Runner Agent

**File:** `agents/team/test-runner.md`
**Model:** claude-sonnet-4-5-20250929
**Color:** green
**Type:** Read-Only
**Description:** Runs quality checks (tests, linting, type checking) without modifying code

**Use when:**

- Before committing code
- After implementing features
- Pre-deployment validation
- CI/CD simulation

**Disallowed Tools:** Write, Edit, NotebookEdit

**Available Tools:**

- `uv run ruff check .` - Python linting
- `uv run ty check .` - Type checking
- `uv run pytest -v` - Test execution

**Example invocation:**

```typescript
Task({
  subagent_type: "test-runner",
  description: "Run quality checks",
  prompt: "Run ruff, ty, and pytest on all Python files in .claude/hooks/"
})
```

#### Pre-Flight Agent

**File:** `agents/team/pre-flight.md`
**Model:** claude-haiku-4-5-20251001
**Color:** blue
**Type:** Read-only
**Description:** Validates environment readiness before work begins

**Use when:**

- Before starting a work session
- After fresh git clone or environment setup
- Before major work or deployments
- When troubleshooting environment issues
- Weekly environment health checks

**Disallowed Tools:** Write, Edit, NotebookEdit

**Example invocation:**

```typescript
Task({
  subagent_type: "pre-flight",
  description: "Environment validation",
  prompt: "Run comprehensive pre-flight check - verify all tools, credentials, git status, and dependencies"
})
```

### Utility Agents (Support)

#### Meta-Agent

**File:** `agents/meta-agent.md`
**Model:** claude-sonnet-4-5-20250929
**Color:** cyan
**Description:** Generates new agent definitions from user descriptions

**Use when:**

- Creating specialized agents
- Automating domain-specific workflows
- Need task-specific validation

#### Work-Completion-Summary Agent

**File:** `agents/work-completion-summary.md`
**Model:** claude-sonnet-4-5-20250929
**Color:** green
**Description:** Generates audio summaries when work completes

**Use when:**

- After completing major work
- Want audio summary of changes
- Need concise overview with next steps

## 🪝 Hooks System

### Event Flow

```Text
User Input → UserPromptSubmit → PreToolUse → Execute Tool
                                                  ↓
                                    ┌─────────────┴─────────────┐
                                    ↓                           ↓
                                Success                      Failure
                                    ↓                           ↓
                            PostToolUse                PostToolUseFailure
                                    ↓                           ↓
                            Validators (Ruff, Ty)         Log Error
                                    ↓
                            Quality Report
```

### Active Hooks

| Hook                       | Event                     | Purpose                          |
|----------------------------|---------------------------|----------------------------------|
| `user_prompt_submit.py`    | User input                | Log user prompts                 |
| `pre_tool_use.py`          | Before tool execution     | Log tool calls                   |
| `post_tool_use.py`         | After successful tool     | Log results, run validators      |
| `post_tool_use_failure.py` | After tool failure        | Log errors                       |
| `session_start.py`         | Session initialization    | Setup logging                    |
| `session_end.py`           | Session cleanup           | Finalize logs                    |
| `subagent_start.py`        | Subagent launch           | Track agent lifecycle            |
| `subagent_stop.py`         | Subagent completion       | Log agent results                |
| `pre_compact.py`           | Before context compaction | Prepare session state            |

### Validators

**Ruff Validator** (`hooks/validators/ruff_validator.py`)

- Runs on Write|Edit tool use
- Checks Python code style (PEP 8)
- Reports linting errors with file:line references
- Non-blocking (reports only)

**Ty Validator** (`hooks/validators/ty_validator.py`)

- Runs on Write|Edit tool use
- Checks type annotations
- Reports type errors with file:line references
- Non-blocking (reports only)

## 📊 Model Selection Strategy

| Agent        | Model      | Rationale                                   |
|--------------|------------|---------------------------------------------|
| Builder      | Opus 4.5   | Complex implementation, critical changes    |
| Validator    | Opus 4.5   | Thorough verification, quality assurance    |
| Test-Runner  | Sonnet 4.5 | Fast execution, standard quality checks     |
| Pre-Flight   | Haiku 4.5  | Fast environment checks, simple validation  |
| Meta-Agent   | Sonnet 4.5 | Standard agent creation                     |
| Work-Summary | Sonnet 4.5 | Fast summary generation                     |
| LLM Hooks    | Haiku 4.5  | Simple prompts, cost-effective              |

## 🔧 Configuration

### settings.json

Main configuration file with:

- Permission modes (default, auto-yes)
- Enabled hooks (all events)
- Tool permissions
- Shell environment settings
- Agent configurations

### Environment Variables

Required for full functionality:

- `ANTHROPIC_API_KEY` - For LLM hooks (completion messages, agent naming)
- `ELEVENLABS_API_KEY` - For TTS summaries
- `CLAUDE_PROJECT_DIR` - Auto-set to project root

## 📈 Success Metrics

**This configuration achieved:**

- ✅ 100% success rate (6/6 agents)
- ✅ 1,595+ lines of production code generated
- ✅ Zero manual corrections needed
- ✅ Full automated validation
- ✅ Comprehensive documentation

## 📚 Documentation

- **[AGENT-ORCHESTRATION-GUIDE.md](../docs/AGENT-ORCHESTRATION-GUIDE.md)** - Complete reference guide
- **[TEST-RUNNER-USAGE.md](../docs/TEST-RUNNER-USAGE.md)** - Test-runner agent guide
- **[DEPLOYMENT.md](../docs/DEPLOYMENT.md)** - Deployment workflows
- **[CLAUDE.md](../CLAUDE.md)** - Project context for agents

## 🚀 Quick Start

### Run Quality Checks

```typescript
Task({
  subagent_type: "test-runner",
  description: "Full quality check",
  prompt: "Run ruff, ty, and pytest on entire codebase"
})
```

### Implement Feature

```typescript
Task({
  subagent_type: "builder",
  description: "Add feature",
  prompt: "Create new deployment script with health checks and rollback"
})
```

### Validate Work

```typescript
Task({
  subagent_type: "validator",
  description: "Verify implementation",
  prompt: "Validate that deployment script meets acceptance criteria: health checks, rollback, proper error handling"
})
```

## 🔄 Common Workflows

### Pre-Commit Workflow

```typescript
// 1. Run quality checks
Task({ subagent_type: "test-runner", ... })

// 2. Fix issues (if any)
Task({ subagent_type: "builder", ... })

// 3. Re-validate
Task({ subagent_type: "test-runner", ... })
```

### Feature Implementation Workflow

```typescript
// 1. Implement
Task({ subagent_type: "builder", ... })

// 2. Validate completion
Task({ subagent_type: "validator", ... })

// 3. Quality check
Task({ subagent_type: "test-runner", ... })
```

## 🛠️ Maintenance

### Updating Agents

Edit the agent definition files in `agents/team/`:

- Modify frontmatter (model, color, disallowedTools)
- Update instructions section
- Adjust workflow steps
- Changes take effect immediately

### Adding New Hooks

1. Create hook file in `hooks/`
2. Add to `settings.json` under appropriate event
3. Test with sample tool execution
4. Monitor logs in `../logs/`

### Installing to New Project

Use the universal setup script:

```bash
bash setup-claude-agents.sh /path/to/new/project --type=python
```

## 📞 Support

For issues or questions:

- See [AGENT-ORCHESTRATION-GUIDE.md](../docs/AGENT-ORCHESTRATION-GUIDE.md)
- Check logs in `../logs/`
- Review hook outputs in `../logs/*.json`

---

**Last Updated:** 2026-02-06
**Configuration Version:** 1.0
**Success Rate:** 100%
