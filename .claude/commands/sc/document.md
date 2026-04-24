---
name: document
description: "Generate focused documentation for components, functions, APIs, and features"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /sc:document - Focused Documentation Generation

## Triggers
- Documentation requests for components, functions, APIs, or features
- Code comment, inline documentation, or user guide creation

## Usage
```
/sc:document [target] [--type inline|external|api|guide] [--style brief|detailed]
```

## Behavioral Flow
1. **Analyze** (structure/interfaces) → **Identify** (requirements/audience) → **Generate** (content by type/style) → **Format** (consistent structure) → **Integrate** (existing ecosystem)

## Tool Coordination
| Tool | Role |
|------|------|
| Read | Component analysis, existing doc review |
| Grep | Reference extraction, pattern identification |
| Write | Documentation file creation |
| Glob | Multi-file documentation projects |

## Key Patterns
| Type | Flow |
|------|------|
| Inline | code analysis → JSDoc/docstring → inline comments |
| API | interface extraction → reference material → usage examples |
| Guide | feature analysis → tutorial content → implementation guidance |
| External | component overview → specifications → integration instructions |

## Examples
- `/sc:document src/auth/login.js --type inline` — JSDoc with params, returns, inline comments
- `/sc:document src/api --type api --style detailed` — endpoints, schemas, usage examples
- `/sc:document payment-module --type guide --style brief` — practical examples, common use cases
- `/sc:document components/ --type external` — props, usage, integration patterns

## Boundaries
- **Will**: generate focused docs in multiple formats, integrate with existing ecosystem
- **Will Not**: generate without code analysis, override existing conventions, expose sensitive details
