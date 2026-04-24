---
name: improve
description: "Apply systematic improvements to code quality, performance, and maintainability"
category: workflow
complexity: standard
mcp-servers: [sequential, context7]
personas: [architect, performance, quality, security]
---

# /sc:improve - Code Improvement

## Triggers
Code quality enhancement, performance optimization, maintainability improvements, best practices enforcement.

## Usage
```
/sc:improve [target] [--type quality|performance|maintainability|style] [--safe] [--interactive]
```

## Behavioral Flow
1. **Analyze**: Examine codebase for improvement opportunities
2. **Plan**: Choose approach, activate relevant personas
3. **Execute**: Apply systematic improvements with best practices
4. **Validate**: Ensure functionality preserved, quality standards met
5. **Document**: Improvement summary and recommendations

Key behaviors: Multi-persona coordination (architect, performance, quality, security), Context7 framework-specific optimization, Sequential MCP for complex analysis, safe refactoring with rollback.

## MCP Integration
- **Sequential**: Complex multi-step improvement analysis
- **Context7**: Framework-specific best practices
- **Personas**: Architect (structure), Performance (speed), Quality (maintainability), Security (safety)

## Tool Coordination
Read/Grep/Glob (analysis), Edit/MultiEdit (safe modification), TodoWrite (progress), Task (large-scale delegation)

## Key Patterns
- **Quality**: Analysis → debt identification → refactoring
- **Performance**: Profiling → bottleneck ID → optimization
- **Maintainability**: Structure analysis → complexity reduction → docs improvement
- **Security**: Vulnerability analysis → security patterns → validation

## Examples
```bash
/sc:improve src/ --type quality --safe
/sc:improve api-endpoints --type performance --interactive
/sc:improve legacy-modules --type maintainability --preview
/sc:improve auth-service --type security --validate
```

## AUTO-FIX VS APPROVAL-REQUIRED

**Auto-fix**: Style fixes, unused variable removal, import organization, simple type annotations

**Approval Required**: Architectural changes, logic refactoring, function signature changes, removing public API code, multi-file changes

**Will NOT without `--force`**: Make architectural decisions, refactor structure without confirmation, remove functionality.
