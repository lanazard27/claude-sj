---
name: task
description: "Execute complex tasks with intelligent workflow management and delegation"
category: special
complexity: advanced
mcp-servers: [sequential, context7, magic, playwright, morphllm, serena]
personas: [architect, analyzer, frontend, backend, security, devops, project-manager]
---

# /sc:task - Enhanced Task Management

## Triggers
Complex tasks needing multi-agent coordination, structured workflow management, intelligent MCP routing, systematic execution.

## Usage
```
/sc:task [action] [target] [--strategy systematic|agile|enterprise] [--parallel] [--delegate]
```

## Behavioral Flow
1. **Analyze**: Parse task requirements, determine optimal strategy
2. **Delegate**: Route to MCP servers, activate personas
3. **Coordinate**: Execute with intelligent workflow and parallel processing
4. **Validate**: Quality gates and completion verification
5. **Optimize**: Performance analysis and enhancement recommendations

Key behaviors: Multi-persona coordination, intelligent MCP routing, progressive enhancement, cross-session persistence, hierarchical breakdown.

## MCP Integration
- **Sequential**: Complex multi-step analysis and planning
- **Context7**: Framework-specific patterns
- **Magic**: UI/UX coordination
- **Playwright**: Testing validation
- **Morphllm**: Large-scale transformation
- **Serena**: Cross-session persistence

## Tool Coordination
- **TodoWrite**: Hierarchical breakdown (Epic → Story → Task)
- **Task**: Advanced delegation for multi-agent coordination
- **Read/Write/Edit**: Documentation and implementation
- **sequentialthinking**: Dependency analysis

## Key Patterns
- Task Hierarchy: Epic → Story → Task → Subtask
- Strategy Selection: Systematic (comprehensive) | Agile (iterative) | Enterprise (governance)
- Multi-Agent: Persona activation → MCP routing → parallel execution → integration
- Cross-Session: Task persistence → context continuity → progressive enhancement

## Examples
```bash
/sc:task create "enterprise authentication system" --strategy systematic --parallel
/sc:task execute "feature backlog" --strategy agile --delegate
/sc:task execute "microservices platform" --strategy enterprise --parallel
```

## CRITICAL BOUNDARIES

**USER-INVOKED DISCRETE TASK EXECUTION**

- `/sc:pm` = session-level orchestration (background, continuous)
- `/sc:task` = user-invoked discrete execution (explicit start/end)

**Behavior**: Execute specific task → **STOP when complete** — do not continue without user input.

**Completion**: Task objective achieved + all sub-tasks completed + validation passed.

**Output**: Task completion report with accomplishments, modified files, test status.

**Next Step**: User decides. May invoke another `/sc:task` or use specific commands.
