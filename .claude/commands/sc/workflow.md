---
name: workflow
description: "Generate structured implementation workflows from PRDs and feature requirements"
category: orchestration
complexity: advanced
mcp-servers: [sequential, context7, magic, playwright, morphllm, serena]
personas: [architect, analyzer, frontend, backend, security, devops, project-manager]
---

# /sc:workflow - Implementation Workflow Generator

## Triggers
PRD analysis, structured workflow generation, multi-persona coordination, cross-session workflow management.

## Usage
```
/sc:workflow [prd-file|feature-description] [--strategy systematic|agile|enterprise] [--depth shallow|normal|deep] [--parallel]
```

## Behavioral Flow
1. **Analyze**: Parse PRD/specs to understand implementation requirements
2. **Plan**: Generate workflow with dependency mapping and task orchestration
3. **Coordinate**: Activate personas for domain expertise
4. **Execute**: Create structured step-by-step workflows
5. **Validate**: Quality gates and completeness checks

Key behaviors: Multi-persona orchestration, MCP coordination with intelligent routing, progressive enhancement, cross-session management.

## MCP Integration
- **Sequential**: Complex workflow analysis and planning
- **Context7**: Framework-specific workflow patterns
- **Magic**: UI/UX workflow generation
- **Playwright**: Testing workflow integration
- **Morphllm**: Large-scale workflow transformation
- **Serena**: Cross-session persistence

## Tool Coordination
Read/Write/Edit (PRD analysis + workflow docs), TodoWrite (progress), Task (delegation), WebSearch (research), sequentialthinking (reasoning)

## Key Patterns
- PRD Analysis → requirement extraction → strategy development
- Workflow Generation → task decomposition → dependency mapping → planning
- Multi-Domain Coordination → cross-functional expertise
- Quality Integration → validation → testing → deployment planning

## Examples
```bash
/sc:workflow Claudedocs/PRD/feature-spec.md --strategy systematic --depth deep
/sc:workflow "user authentication system" --strategy agile --parallel
/sc:workflow enterprise-prd.md --strategy enterprise --validate
/sc:workflow project-brief.md --depth normal
```

## CRITICAL BOUNDARIES

**STOP AFTER PLAN CREATION** — This produces an IMPLEMENTATION PLAN ONLY, no code execution.

**Will NOT**: Execute tasks, write/modify code, create files (except workflow plan), make architectural changes, run builds/tests.

**Output**: Workflow plan (`claudedocs/workflow_*.md`) with implementation phases, task dependencies, execution order, checkpoints.

**Next Step**: Use `/sc:implement` to execute the plan step by step.
