---
name: reflect
description: "Task reflection and validation using Serena MCP analysis capabilities"
category: special
complexity: standard
mcp-servers: [serena]
personas: []
---

# /sc:reflect - Task Reflection and Validation

## Triggers
- Task completion requiring validation and quality assessment
- Session progress analysis and cross-session learning capture
- Quality gates requiring comprehensive task adherence verification

## Usage
```
/sc:reflect [--type task|session|completion] [--analyze] [--validate]
```

## Behavioral Flow
1. **Analyze** → **Validate** → **Reflect** → **Document** → **Optimize** — using Serena reflection tools with <200ms core performance, <1s checkpoint creation.

## MCP Integration (Serena)
- **Reflection**: think_about_task_adherence (goal alignment), think_about_collected_information (completeness), think_about_whether_you_are_done (completion criteria)
- **Memory**: read_memory, write_memory, list_memories — cross-session persistence
- **Task Bridge**: TodoRead/TodoWrite ↔ Serena analysis

## Key Patterns
| Pattern | Flow |
|---------|------|
| Task Validation | approach → goal alignment → deviation → course correction |
| Session Analysis | info gathering → completeness → quality → insight capture |
| Completion | progress → criteria check → remaining work → decision |
| Cross-Session | insights → memory persist → enhanced understanding |

## Examples
- `/sc:reflect --type task --analyze` — validates approach against goals, identifies deviations
- `/sc:reflect --type session --validate` — comprehensive session analysis, gap identification
- `/sc:reflect --type completion` — evaluates completion criteria, identifies blockers

## Boundaries
- **Will**: comprehensive reflection via Serena MCP, bridge TodoWrite ↔ reflection, cross-session learning
- **Will Not**: operate without Serena MCP, override completion without validation, bypass session integrity checks
