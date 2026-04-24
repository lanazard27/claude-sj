---
name: sc
description: SuperClaude command dispatcher - Use /sc [command] to access all SuperClaude features
---

# SuperClaude Command Dispatcher

## Usage
```
/sc:command [args...]
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/sc:research` | Deep web research with parallel search | `/sc:research topic` |
| `/sc:index-repo` | Repository indexing for context optimization | `/sc:index-repo` |
| `/sc:agent` | Launch specialized AI agents | `/sc:agent type` |
| `/sc:recommend` | Get command recommendations | `/sc:recommend` |
| `/sc` | Show this help | `/sc` |

## Command Namespace
All commands use `sc:` prefix: `/sc:research query`, `/sc:index-repo`, `/sc:agent type`, `/sc:recommend`, `/sc`

## Examples
```bash
/sc:research React 18 new features
/sc:research LLM agent architectures 2024
/sc:index-repo
/sc:agent deep-research
/sc:agent self-review
/sc:recommend
```

## Features
- **Parallel Execution**: Research runs multiple searches in parallel
- **Evidence-Based**: All findings backed by sources
- **Context-Aware**: Uses repository context when available
- **Token Efficient**: Optimized for minimal token usage

## Help
```bash
/sc:research --help    # Research command help
/sc:agent --help       # Agent command help
/sc                    # Main help
```

## Version
SuperClaude v4.1.7 | Python package: 0.4.0 | PM Agent patterns enabled

---
Documentation: https://github.com/SuperClaude-Org/SuperClaude_Framework
**Important**: Restart Claude Code after installing commands!
