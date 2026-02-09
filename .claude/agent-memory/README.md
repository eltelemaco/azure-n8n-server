# Agent Memory

This directory contains memory files for agents and subagents.

## Structure

```
agent-memory/
├── README.md           # This file
├── MEMORY.md           # Main agent memory index
├── builder/            # Builder agent memories
├── validator/          # Validator agent memories
├── explorer/           # Explorer agent memories
└── custom/             # Custom agent memories
```

## Usage

Agents can read and write to their respective subdirectories to maintain context across sessions.
