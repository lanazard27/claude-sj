---
name: spawn
description: "Meta-system task orchestration with intelligent breakdown and delegation"
category: special
complexity: high
mcp-servers: []
personas: []
---

# /sc:spawn - Meta-System Task Orchestration

## Triggers
Complex multi-domain operations, large-scale system operations, parallel coordination, meta-level orchestration.

## Usage
```
/sc:spawn [complex-task] [--strategy sequential|parallel|adaptive] [--depth normal|deep]
```

## Behavioral Flow
1. **Analyze**: Parse requirements, assess scope across domains
2. **Decompose**: Break into coordinated subtask hierarchies (Epic → Story → Task → Subtask)
3. **Orchestrate**: Execute with optimal strategy (parallel/sequential)
4. **Monitor**: Track progress with dependency management
5. **Integrate**: Aggregate results, provide orchestration summary

Key behaviors: Meta-system decomposition, intelligent strategy selection, cross-domain management, advanced dependency analysis.

## MCP Integration
Native orchestration without MCP dependencies. Progressive integration with SuperClaude orchestration layers.

## Tool Coordination
- **TodoWrite**: Hierarchical task breakdown (Epic → Story → Task)
- **Read/Grep/Glob**: System analysis and dependency mapping
- **Edit/MultiEdit/Write**: Coordinated file operations
- **Bash**: System-level operations

## Key Patterns
- **Hierarchical Breakdown**: Epic → Story → Task → Subtask
- **Strategy**: Sequential (dependency-ordered) | Parallel (independent) | Adaptive (dynamic)
- **Coordination**: Cross-domain → resource optimization → integration
- **Enhancement**: Systematic execution → quality gates → validation

## Examples
```bash
/sc:spawn "implement user authentication system"
/sc:spawn "migrate legacy monolith to microservices" --strategy adaptive --depth deep
/sc:spawn "establish CI/CD pipeline with security scanning"
```

## CRITICAL BOUNDARIES

**STOP AFTER TASK DECOMPOSITION** — This produces a TASK HIERARCHY ONLY, delegates execution to other commands.

**Will NOT**: Execute implementation, write/modify code, create system changes, replace domain-specific commands.

**Output**: Task breakdown with Epic decomposition, hierarchy with dependencies, delegation assignments (which `/sc:*` command handles each), coordination strategy.

**Next Step**: Execute tasks using delegated commands (`/sc:implement`, `/sc:design`, `/sc:test`, etc.).
