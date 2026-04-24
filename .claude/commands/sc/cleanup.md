---
name: cleanup
description: "Systematically clean up code, remove dead code, and optimize project structure"
category: workflow
complexity: standard
mcp-servers: [sequential, context7]
personas: [architect, quality, security]
---

# /sc:cleanup - Code and Project Cleanup

## Triggers
Code maintenance, dead code removal, project structure improvement, codebase hygiene.

## Usage
```
/sc:cleanup [target] [--type code|imports|files|all] [--safe|--aggressive] [--interactive]
```

## Behavioral Flow
1. **Analyze**: Assess cleanup opportunities and safety
2. **Plan**: Choose approach, activate personas (architect, quality, security)
3. **Execute**: Systematic cleanup with intelligent dead code detection
4. **Validate**: No functionality loss through testing and safety verification
5. **Report**: Cleanup summary with maintenance recommendations

Key behaviors: Multi-persona coordination, Context7 framework-specific patterns, Sequential MCP for complex analysis, safety-first with backup/rollback.

## MCP Integration
- **Sequential**: Complex multi-step cleanup analysis
- **Context7**: Framework-specific cleanup patterns
- **Personas**: Architect (structure), Quality (debt), Security (credentials)

## Tool Coordination
Read/Grep/Glob (analysis), Edit/MultiEdit (safe modification), TodoWrite (progress), Task (large-scale delegation)

## Key Patterns
- **Dead Code**: Usage analysis → safe removal with dependency validation
- **Import Optimization**: Dependency analysis → unused import removal
- **Structure Cleanup**: Architecture analysis → file organization
- **Safety**: Pre/during/post checks → preserve functionality

## Examples
```bash
/sc:cleanup src/ --type code --safe
/sc:cleanup --type imports --preview
/sc:cleanup --type all --interactive
/sc:cleanup components/ --aggressive
```

## AUTO-FIX VS APPROVAL-REQUIRED

**Auto-fix**: Unused imports, dead code with zero references, empty blocks, redundant type annotations

**Approval Required**: Code with indirect references, exports potentially used externally, test fixtures/utilities, configuration values

**Safety Threshold**: If ANY usage path exists → prompt user. If affects public API → prompt user. If unsure → prompt user.
