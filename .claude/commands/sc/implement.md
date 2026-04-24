---
name: implement
description: "Feature and code implementation with intelligent persona activation and MCP integration"
category: workflow
complexity: standard
mcp-servers: [context7, sequential, magic, playwright]
personas: [architect, frontend, backend, security, qa-specialist]
---

# /sc:implement - Feature Implementation

## Triggers
Feature development, code implementation with framework requirements, multi-domain development, implementation with testing/validation.

## Usage
```
/sc:implement [feature-description] [--type component|api|service|feature] [--framework react|vue|express] [--safe] [--with-tests]
```

## Behavioral Flow
1. **Analyze**: Examine requirements, detect technology context
2. **Plan**: Choose approach, activate relevant personas (architect, frontend, backend, security, qa)
3. **Generate**: Create implementation with framework-specific best practices
4. **Validate**: Security and quality validation throughout
5. **Integrate**: Update documentation, provide testing recommendations

Key behaviors: Context-based persona activation, Context7 + Magic MCP for framework-specific implementation, Sequential for multi-component coordination, Playwright for validation.

## MCP Integration
- **Context7**: Framework patterns and official docs (React, Vue, Angular, Express)
- **Magic**: Auto-activated for UI component generation
- **Sequential**: Complex multi-step implementation planning
- **Playwright**: Testing validation and QA integration

## Tool Coordination
Write/Edit/MultiEdit (code), Read/Grep/Glob (analysis), TodoWrite (progress), Task (delegation)

## Key Patterns
- **Context Detection**: Framework → persona + MCP activation
- **Implementation Flow**: Requirements → code → validation → integration
- **Multi-Persona**: Frontend + Backend + Security → comprehensive solutions
- **Quality**: Implementation → testing → documentation → validation

## Examples
```bash
/sc:implement user profile component --type component --framework react
/sc:implement user authentication API --type api --safe --with-tests
/sc:implement payment processing system --type feature --with-tests
/sc:implement dashboard widget --framework vue
```

## COMPLETION CRITERIA

**Done when**: Code written + compiles + basic functionality verified + files saved.

**Post-Implementation Checklist**: 1) Compiles without errors 2) Basic functionality works 3) Ready for `/sc:test`

**Next Step**: Use `/sc:test` to run tests, then `/sc:git` to commit.
