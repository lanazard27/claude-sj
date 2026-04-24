---
name: help
description: "List all available /sc commands and their functionality"
category: utility
complexity: low
mcp-servers: []
personas: []
---

# /sc:help - Command Reference Documentation

## Triggers
Command discovery, reference lookup, framework exploration, capability understanding.

## Behavior
Information display only — no execution or implementation.

## Available Commands

| Command | Description |
|---------|-------------|
| `/sc:analyze` | Comprehensive code analysis (quality, security, performance, architecture) |
| `/sc:brainstorm` | Interactive requirements discovery through Socratic dialogue |
| `/sc:build` | Build, compile, package with intelligent error handling |
| `/sc:business-panel` | Multi-expert business analysis with adaptive interaction modes |
| `/sc:cleanup` | Clean up code, remove dead code, optimize project structure |
| `/sc:design` | Design system architecture, APIs, component interfaces |
| `/sc:document` | Generate focused documentation for components, functions, APIs |
| `/sc:estimate` | Development estimates for tasks, features, projects |
| `/sc:explain` | Clear explanations of code, concepts, system behavior |
| `/sc:git` | Git operations with intelligent commit messages |
| `/sc:help` | List all available /sc commands |
| `/sc:implement` | Feature/code implementation with persona activation and MCP |
| `/sc:improve` | Systematic improvements to code quality, performance, maintainability |
| `/sc:index` | Generate comprehensive project documentation and knowledge base |
| `/sc:load` | Session lifecycle management with Serena MCP |
| `/sc:reflect` | Task reflection and validation using Serena MCP |
| `/sc:save` | Session context persistence with Serena MCP |
| `/sc:select-tool` | Intelligent MCP tool selection based on complexity scoring |
| `/sc:spawn` | Meta-system task orchestration with intelligent breakdown |
| `/sc:spec-panel` | Multi-expert specification review and improvement |
| `/sc:task` | Complex task execution with intelligent workflow management |
| `/sc:test` | Execute tests with coverage analysis and quality reporting |
| `/sc:troubleshoot` | Diagnose and resolve issues in code, builds, deployments |

## SuperClaude Framework Flags

### Mode Activation
| Flag | Trigger | Behavior |
|------|---------|----------|
| `--brainstorm` | Vague requests, exploration | Collaborative discovery, probing questions |
| `--introspect` | Self-analysis, error recovery | Expose thinking with transparency markers |
| `--task-manage` | >3 step operations | Orchestrate through delegation |
| `--orchestrate` | Multi-tool, parallel execution | Optimize tool selection, parallel thinking |
| `--token-efficient` | Context >75%, large-scale | Symbol communication, 30-50% token reduction |

### MCP Server Flags
| Flag | Trigger | Behavior |
|------|---------|----------|
| `--c7` / `--context7` | Library/framework questions | Curated documentation lookup |
| `--seq` / `--sequential` | Complex debugging, system design | Structured multi-step reasoning |
| `--magic` | UI component requests | Modern UI generation from 21st.dev |
| `--morph` / `--morphllm` | Bulk code transformations | Efficient multi-file pattern application |
| `--serena` | Symbol operations, project memory | Semantic understanding, session persistence |
| `--play` / `--playwright` | Browser testing, E2E | Real browser automation |
| `--all-mcp` | Maximum complexity | Enable all MCP servers |
| `--no-mcp` | Native-only execution | Disable all MCP servers |

### Analysis Depth
| Flag | Trigger | Behavior |
|------|---------|----------|
| `--think` | Multi-component analysis | Standard analysis (~4K tokens) |
| `--think-hard` | Architectural analysis | Deep analysis (~10K tokens) + Context7 |
| `--ultrathink` | Critical system redesign | Maximum depth (~32K tokens) + all MCP |

### Execution Control
| Flag | Trigger | Behavior |
|------|---------|----------|
| `--delegate [auto\|files\|folders]` | >7 dirs OR >50 files | Sub-agent parallel processing |
| `--concurrency [n]` | Resource optimization | Max concurrent operations (1-15) |
| `--loop` | Improvement keywords | Iterative improvement with validation |
| `--iterations [n]` | Specific cycle requirements | Cycle count (1-10) |
| `--validate` | Risk >0.7, resource >75% | Pre-execution risk assessment |
| `--safe-mode` | Resource >85%, production | Maximum validation, conservative |

### Output Optimization
| Flag | Trigger | Behavior |
|------|---------|----------|
| `--uc` / `--ultracompressed` | Context pressure | Symbol communication, 30-50% reduction |
| `--scope [file\|module\|project\|system]` | Analysis boundary | Define operational scope |
| `--focus [domain]` | Domain-specific | Target specific analysis domain |

### Flag Priority Rules
- Safety First: `--safe-mode` > `--validate` > optimization
- Explicit Override: User flags > auto-detection
- Depth: `--ultrathink` > `--think-hard` > `--think`
- MCP: `--no-mcp` overrides all individual MCP flags
- Scope: system > project > module > file

### Usage Examples
```bash
/sc:analyze --think-hard --context7 src/
/sc:implement --magic --validate "Add user dashboard"
/sc:task --token-efficient --delegate auto "Refactor auth system"
/sc:build --safe-mode --validate --focus security
```

## Boundaries
**Will**: Display command list, descriptions, flags, usage examples, priority rules
**Will Not**: Execute commands, create files, activate modes, use TodoWrite

---
**Note:** This list is manually maintained and may become outdated.
