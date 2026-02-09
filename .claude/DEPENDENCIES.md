# Dependency Management Guide

## Overview

This project uses **uv** for Python dependency management with a **dual approach**:

1. **PEP 723 Inline Script Dependencies** - For individual hook scripts (no venv needed)
2. **Project-level pyproject.toml** - For shared dependencies and development tools

## Why Both Approaches?

### PEP 723 (Inline Script Dependencies)

Each hook script declares its own dependencies:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///
```

**Advantages:**
- ✅ Scripts are self-contained and portable
- ✅ No virtual environment activation needed
- ✅ Dependencies automatically managed by `uv run --script`
- ✅ Clear dependency isolation per script

### Project-level pyproject.toml

Centralizes common dependencies and development tools.

**Advantages:**
- ✅ Single source of truth for project metadata
- ✅ Easier dependency updates across all scripts
- ✅ Development tool configuration (ruff, ty, pytest)
- ✅ Optional dependency groups for different use cases

## Installation Options

### Option 1: No Installation (Recommended for Hooks)

Hooks run via `uv run --script` without any installation:

```bash
# Run any hook directly
uv run .claude/hooks/session_start.py

# Or use shebang
./.claude/hooks/session_start.py
```

Dependencies are automatically resolved from inline metadata.

### Option 2: Install Core Dependencies

Install only core dependencies:

```bash
uv pip install -e .
```

### Option 3: Install with Optional Groups

Install specific optional dependency groups:

```bash
# Install with LLM support
uv pip install -e ".[llm]"

# Install with TTS support
uv pip install -e ".[tts]"

# Install development tools
uv pip install -e ".[dev]"

# Install everything
uv pip install -e ".[all]"
```

### Option 4: Sync All Dependencies

Use uv's sync command for development:

```bash
# Create/update virtual environment with all dependencies
uv sync

# Sync only dev dependencies
uv sync --group dev

# Sync including optional groups
uv sync --extra all
```

## Dependency Groups

### Core Dependencies (Always Installed)

```toml
dependencies = [
    "python-dotenv>=1.0.0",
]
```

Used by: Most hooks for environment variable management

### Optional: LLM Integration

```toml
[project.optional-dependencies.llm]
llm = [
    "anthropic>=0.39.0",
    "openai>=1.0.0",
]
```

Used by:
- `subagent_stop.py` - AI-powered summaries
- `.claude/hooks/utils/llm/anth.py` - Anthropic API integration
- `.claude/hooks/utils/llm/oai.py` - OpenAI API integration

### Optional: TTS Integration

```toml
[project.optional-dependencies.tts]
tts = [
    "elevenlabs>=1.0.0",
    "openai[voice_helpers]>=1.0.0",
    "pyttsx3>=2.90",
]
```

Used by:
- `.claude/hooks/utils/tts/elevenlabs_tts.py` - ElevenLabs TTS
- `.claude/hooks/utils/tts/openai_tts.py` - OpenAI TTS
- `.claude/hooks/utils/tts/pyttsx3_tts.py` - Offline TTS
- `notification.py` - Audio notifications
- `subagent_stop.py` - Audio summaries

### Optional: Development Tools

```toml
[project.optional-dependencies.dev]
dev = [
    "ruff>=0.8.0",
    "ty>=0.1.0",
    "pytest>=8.0.0",
    "pytest-cov>=6.0.0",
]
```

Used for:
- Code linting (`uv run ruff check .`)
- Type checking (`uv run ty check .`)
- Testing (`uv run pytest`)

## Common Commands

### Development Workflow

```bash
# Install development dependencies
uv pip install -e ".[dev]"

# Run linter
uv run ruff check .
uv run ruff check --fix .

# Run type checker
uv run ty check .

# Run tests
uv run pytest

# Run tests with coverage
uv run pytest --cov
```

### Hook Development

```bash
# Test a hook directly (no installation needed)
echo '{"session_id": "test"}' | uv run .claude/hooks/session_start.py

# Run hook with dependencies
uv run .claude/hooks/subagent_stop.py --notify

# Check hook syntax
uv run ruff check .claude/hooks/session_start.py

# Type check hook
uv run ty check .claude/hooks/session_start.py
```

### Dependency Management

```bash
# Update all dependencies
uv pip install --upgrade -e ".[all]"

# List installed packages
uv pip list

# Show dependency tree
uv pip show anthropic

# Check for outdated packages
uv pip list --outdated
```

## Updating Dependencies

### Update Inline Script Dependencies

Edit the PEP 723 metadata in the script:

```python
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv>=1.0.1",  # Update version
# ]
# ///
```

### Update Project-level Dependencies

Edit `pyproject.toml`:

```toml
[project]
dependencies = [
    "python-dotenv>=1.0.1",  # Update version
]
```

Then reinstall:

```bash
uv pip install -e .
```

## Adding New Dependencies

### For a Single Hook

Add to inline metadata:

```python
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
#     "requests>=2.31.0",  # New dependency
# ]
# ///
```

### For Project-wide Use

Add to `pyproject.toml`:

```toml
[project]
dependencies = [
    "python-dotenv>=1.0.0",
    "requests>=2.31.0",  # New dependency
]
```

### For Optional Feature

Add to appropriate optional group:

```toml
[project.optional-dependencies]
llm = [
    "anthropic>=0.39.0",
    "openai>=1.0.0",
    "langchain>=0.3.0",  # New LLM tool
]
```

## Environment Variables

Required environment variables for optional features:

```bash
# For LLM integrations
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."

# For TTS integrations
export ELEVENLABS_API_KEY="..."

# Optional: Claude Code project directory (auto-set)
export CLAUDE_PROJECT_DIR="/path/to/project"
```

Add to `.env` file in project root:

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
ELEVENLABS_API_KEY=...
```

## Configuration Consolidation

All tool configurations are now unified in `pyproject.toml`:

- **Ruff**: `[tool.ruff]` and `[tool.ruff.lint]` sections
- **Ty**: `[tool.ty]` and `[tool.ty.rules]` sections
- **Pytest**: `[tool.pytest.ini_options]` section
- **Coverage**: `[tool.coverage.*]` sections

Previously separate `ruff.toml` and `ty.toml` files have been merged into `pyproject.toml` for easier maintenance.

## Troubleshooting

### Hook Script Won't Run

```bash
# Check shebang permissions
chmod +x .claude/hooks/session_start.py

# Test uv can find script
uv run .claude/hooks/session_start.py

# Check Python version
python --version  # Should be 3.11+
```

### Missing Dependencies

```bash
# For inline scripts, uv installs automatically
uv run .claude/hooks/script.py

# For project dependencies, install manually
uv pip install -e ".[all]"
```

### Import Errors

```bash
# Check if dependency is in inline metadata
head -15 .claude/hooks/script.py

# Or in project dependencies
cat pyproject.toml | grep -A 10 "dependencies"

# Install missing dependency
uv pip install package-name
```

### Type Checking False Positives

PEP 723 inline imports may show as unresolved. This is expected and ignored via `ty.toml`:

```toml
[tool.ty.rules]
unresolved-import = "ignore"
```

## Best Practices

1. **Keep inline dependencies minimal** - Only add what each script needs
2. **Use project dependencies for shared code** - DRY principle
3. **Pin major versions** - `package>=1.0.0` allows minor updates
4. **Test after updates** - Run `uv run pytest` after dependency changes
5. **Document API keys** - Update `.env.example` when adding new services
6. **Use optional groups** - Don't force users to install TTS/LLM if not needed
7. **Check compatibility** - Test scripts after dependency updates

## Migration Path

### From Individual venvs to uv

If you have existing venvs:

```bash
# Remove old venv
rm -rf venv/

# Install uv if not already
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install project dependencies
uv pip install -e ".[all]"

# Test hooks still work
uv run .claude/hooks/session_start.py
```

### From requirements.txt to pyproject.toml

Already done! But if you had a `requirements.txt`:

```bash
# No longer needed - delete it
rm requirements.txt

# Dependencies now in pyproject.toml
uv pip install -e .
```

## References

- [PEP 723 - Inline Script Metadata](https://peps.python.org/pep-0723/)
- [uv Documentation](https://docs.astral.sh/uv/)
- [pyproject.toml Specification](https://packaging.python.org/en/latest/specifications/pyproject-toml/)
- [Ruff Configuration](https://docs.astral.sh/ruff/configuration/)
- [Ty Type Checker](https://docs.astral.sh/ty/)

## Quick Reference

| Task | Command |
|------|---------|
| Run hook | `uv run .claude/hooks/script.py` |
| Install core deps | `uv pip install -e .` |
| Install with LLM | `uv pip install -e ".[llm]"` |
| Install everything | `uv pip install -e ".[all]"` |
| Lint code | `uv run ruff check .` |
| Type check | `uv run ty check .` |
| Run tests | `uv run pytest` |
| Update deps | `uv pip install --upgrade -e ".[all]"` |
| Add to inline | Edit `# /// script` block |
| Add to project | Edit `pyproject.toml` |

---

**Last Updated:** 2026-02-08
**uv Version:** 0.5.0+
**Python Version:** 3.11+
