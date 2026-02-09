# Agent Memory Configuration Guide

## Overview

This guide explains how to manage agent and subagent memory in this project using `.claude/agent-memory`.

## Memory Types in Claude Code

| Type | Location | Purpose | Scope |
|------|----------|---------|-------|
| Auto Memory | `~/.claude/projects/<project>/memory/` | Claude's automatic notes | Per-project, user-specific |
| Project Memory | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team instructions | Shared via git |
| Agent Memory (Custom) | `./.claude/agent-memory/` | Agent-specific context | Project-specific |
| Project Rules | `./.claude/rules/*.md` | Modular instructions | Shared via git |

## Configuration Options

### Option 1: Use Project-Level Agent Memory (Recommended)

Store agent memories in `.claude/agent-memory/` for version control:

```bash
.claude/agent-memory/
├── MEMORY.md              # Agent memory index
├── builder/               # Builder agent memories
├── validator/             # Validator agent memories
├── explorer/              # Explorer agent memories
└── patterns/              # Common patterns and learnings
```

**Advantages:**
- ✓ Version controlled (team can share)
- ✓ Project-specific
- ✓ Easy to organize by agent type
- ✓ Can be backed up with project

**How to enable:**
Add to your agent instructions in `.claude/agents/*.md`:

```markdown
## Memory Management

Save learnings and patterns to `.claude/agent-memory/<agent-name>/` for persistence across sessions.

When you discover important patterns:
1. Write to `.claude/agent-memory/<agent-name>/MEMORY.md`
2. Create topic files for detailed notes
3. Keep the main MEMORY.md concise
```

### Option 2: Import Agent Memory into CLAUDE.md

Reference agent memories from your main CLAUDE.md:

```markdown
# Agent Memory Imports

Load agent-specific memories:
- @.claude/agent-memory/builder/MEMORY.md
- @.claude/agent-memory/validator/MEMORY.md
- @.claude/agent-memory/explorer/MEMORY.md
```

### Option 3: Use Modular Rules for Agent Instructions

Create agent-specific rules in `.claude/rules/agents/`:

```bash
.claude/rules/agents/
├── builder.md
├── validator.md
├── explorer.md
└── meta-agent.md
```

Each file contains agent-specific instructions and memory.

### Option 4: Environment Variable for Custom Memory Path

Set up custom memory location via environment variables in hooks:

```python
# In .claude/hooks/session_start.py
import os

# Set custom agent memory path
os.environ['AGENT_MEMORY_DIR'] = os.path.join(
    os.environ.get('CLAUDE_PROJECT_DIR', os.getcwd()),
    '.claude/agent-memory'
)
```

Then reference in agent instructions:
```markdown
Store memories in: $AGENT_MEMORY_DIR/<agent-name>/
```

## Recommended Setup for This Project

### 1. Create Agent Memory Structure

```bash
mkdir -p .claude/agent-memory/{builder,validator,explorer,meta-agent}
```

### 2. Add Memory Index

Create `.claude/agent-memory/MEMORY.md`:

```markdown
# Agent Memory Index

## Active Agents

- **builder**: Implementation and code writing
  - See: builder/MEMORY.md
- **validator**: Code validation and testing
  - See: validator/MEMORY.md
- **explorer**: Codebase exploration and analysis
  - See: explorer/MEMORY.md
- **meta-agent**: Agent creation and management
  - See: meta-agent/MEMORY.md

## Shared Patterns

- Build patterns: patterns/builds.md
- Test patterns: patterns/testing.md
- Code patterns: patterns/coding.md
```

### 3. Update Agent Definitions

Add to each agent in `.claude/agents/*.md`:

```markdown
## Memory Persistence

**Memory Location:** `.claude/agent-memory/<agent-name>/`

### When to Save to Memory

Save to memory when you:
- Discover important project patterns
- Learn coding conventions
- Find solutions to recurring problems
- Identify architectural decisions

### Memory Structure

```
.claude/agent-memory/<agent-name>/
├── MEMORY.md           # Concise index of learnings
├── patterns.md         # Common patterns discovered
├── decisions.md        # Key decisions and rationale
└── troubleshooting.md  # Common issues and solutions
```

Keep MEMORY.md under 200 lines. Move detailed notes to topic files.
```

### 4. Add to .gitignore (Optional)

If memories should be user-specific:

```gitignore
# User-specific agent memories
.claude/agent-memory/*/MEMORY.md
.claude/agent-memory/*/personal-*.md
```

## Auto Memory Control

Control Claude's built-in auto memory:

```bash
# Disable auto memory (use only custom agent memory)
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1

# Enable auto memory (use both)
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
```

Add to `.env` or shell profile.

## Memory Best Practices

### For Agents

1. **Be Specific**: Save concrete learnings, not vague notes
2. **Use Structure**: Organize by topic with clear headings
3. **Keep Index Concise**: Main MEMORY.md should be scannable
4. **Reference, Don't Duplicate**: Link to topic files for details
5. **Update Regularly**: Keep memories current as project evolves

### For Teams

1. **Document Memory Strategy**: Explain in project README
2. **Review Periodically**: Update shared memories with team
3. **Use Version Control**: Track memory changes in git
4. **Namespace by Agent**: Separate memories by agent type
5. **Share Learnings**: Commit useful patterns for team benefit

## Testing Your Setup

Verify agent memory configuration:

```bash
# Check directory structure
ls -la .claude/agent-memory/

# Verify agent can access memory
echo "Test memory access" > .claude/agent-memory/test.md

# Check imports in CLAUDE.md
grep -r "@.*agent-memory" .claude/

# Test with agent
# Ask: "Save this pattern to agent memory: <pattern>"
```

## Troubleshooting

### Memory Not Loading

1. Check file paths in imports
2. Verify permissions on memory directory
3. Check first 200 lines of MEMORY.md (auto-loaded limit)
4. Restart Claude Code session

### Memory Not Persisting

1. Ensure directory exists: `.claude/agent-memory/`
2. Check write permissions
3. Verify agent has Write tool access
4. Check .gitignore isn't blocking files

### Subagent Memory Issues

Subagents inherit parent memory but can't modify parent's auto memory.
Give subagents explicit instructions to write to project-level agent memory:

```markdown
Write learnings to `.claude/agent-memory/<agent-name>/` instead of system memory.
```

## Additional Resources

- [Claude Code Memory Docs](https://code.claude.com/docs/en/memory)
- [Agent Configuration Guide](.claude/agents/README.md)
- [Project Memory Setup](.claude/CLAUDE.md)

---

**Last Updated:** 2026-02-08
**Maintained By:** Development Team
