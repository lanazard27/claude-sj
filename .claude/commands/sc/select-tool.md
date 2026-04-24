---
name: select-tool
description: "Intelligent MCP tool selection based on complexity scoring and operation analysis"
category: special
complexity: high
mcp-servers: [serena, morphllm]
personas: []
---

# /sc:select-tool - Intelligent MCP Tool Selection

## Triggers
- Operations requiring optimal MCP tool selection between Serena and Morphllm
- Tool routing decisions requiring performance vs accuracy trade-offs

## Usage
```
/sc:select-tool [operation] [--analyze] [--explain]
```

## Behavioral Flow
1. **Parse** (operation type/scope/file count) → **Score** (multi-dimensional complexity) → **Match** (capabilities) → **Select** (optimal tool) → **Validate** (confidence metrics)

## MCP Integration
| Tool | Best For |
|------|----------|
| **Serena** | Semantic operations, LSP, symbol navigation, project context, memory |
| **Morphllm** | Pattern-based edits, bulk transformations, speed-critical operations |

## Decision Matrix
| Criteria | Selection |
|----------|-----------|
| Symbol operations | → Serena |
| Pattern edits | → Morphllm |
| Memory operations | → Serena |
| Score >0.6 | → Serena |
| Score <0.4 | → Morphllm |
| 0.4–0.6 | → Feature-based decision |
| Speed priority | → Morphllm |
| Accuracy priority | → Serena |
| Fallback chain | Serena → Morphllm → Native tools |

## Tool Coordination
- **get_current_config**: capability assessment
- **execute_sketched_edit**: operation testing/validation
- **Read/Grep**: context analysis and complexity identification

## Examples
- `/sc:select-tool "rename function across 10 files" --analyze` → Serena (multi-file, semantic)
- `/sc:select-tool "update console.log to logger.info" --explain` → Morphllm (pattern, speed)
- `/sc:select-tool "save project context"` → Serena (memory operations)

## Boundaries
- **Will**: analyze and select optimal tool, sub-100ms decision, >95% accuracy
- **Will Not**: override explicit user preference, skip complexity analysis, compromise performance
