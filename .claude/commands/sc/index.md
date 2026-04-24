---
name: index
description: "Generate comprehensive project documentation and knowledge base with intelligent organization"
category: special
complexity: standard
mcp-servers: [sequential, context7]
personas: [architect, scribe, quality]
---

# /sc:index - Project Documentation

## Triggers
- Project documentation creation/maintenance, knowledge base generation
- API documentation, structure analysis, cross-referencing enhancement

## Usage
```
/sc:index [target] [--type docs|api|structure|readme] [--format md|json|yaml]
```

## Behavioral Flow
1. **Analyze** (structure/components) → **Organize** (patterns/cross-refs) → **Generate** (framework-specific) → **Validate** (completeness/quality) → **Maintain** (preserve manual additions)

## MCP Integration
| MCP | Role |
|-----|------|
| **Sequential** | Multi-step systematic analysis |
| **Context7** | Framework-specific patterns and standards |

**Persona Coordination**: Architect (structure) + Scribe (content) + Quality (validation)

## Tool Coordination
| Tool | Role |
|------|------|
| Read/Grep/Glob | Structure analysis, content extraction |
| Write | Documentation creation with cross-referencing |
| TodoWrite | Progress tracking for multi-component workflows |
| Task | Advanced delegation for large-scale documentation |

## Key Patterns
| Pattern | Flow |
|---------|------|
| Structure | examine → identify → organize → cross-reference |
| Types | API docs → Structure docs → README → Knowledge base |
| Quality | completeness → accuracy → standard compliance → maintenance |
| Framework | Context7 patterns → official standards → best practices |

## Examples
- `/sc:index project-root --type structure --format md` — navigable structure with cross-refs
- `/sc:index src/api --type api --format json` — API docs with scribe/quality validation
- `/sc:index . --type docs` — interactive knowledge base with architectural organization

## Boundaries
- **Will**: comprehensive docs with intelligent organization, multi-persona coordination, framework patterns
- **Will Not**: override manual docs without permission, skip analysis/validation, bypass standards
