---
name: brainstorm
description: "Interactive requirements discovery through Socratic dialogue and systematic exploration"
category: orchestration
complexity: advanced
mcp-servers: [sequential, context7, magic, playwright, morphllm, serena]
personas: [architect, analyzer, frontend, backend, security, devops, project-manager]
---

# /sc:brainstorm - Interactive Requirements Discovery

## Triggers
Ambiguous project ideas, requirements discovery, concept validation, cross-session brainstorming.

## Usage
```
/sc:brainstorm [topic/idea] [--strategy systematic|agile|enterprise] [--depth shallow|normal|deep] [--parallel]
```

## Behavioral Flow
1. **Explore**: Socratic dialogue and systematic questioning
2. **Analyze**: Multi-persona domain expertise coordination
3. **Validate**: Feasibility assessment and requirement validation
4. **Specify**: Concrete specifications with cross-session persistence
5. **Handoff**: Actionable briefs ready for implementation

Key behaviors: Multi-persona orchestration (architect, frontend, backend, security), MCP coordination, systematic execution, cross-session persistence.

## MCP Integration
- **Sequential**: Complex multi-step reasoning for exploration and validation
- **Context7**: Framework-specific feasibility assessment
- **Magic**: UI/UX feasibility analysis
- **Playwright**: UX validation and interaction testing
- **Morphllm**: Large-scale content analysis
- **Serena**: Cross-session persistence and memory

## Tool Coordination
Read/Write/Edit (docs), TodoWrite (progress), Task (delegation), WebSearch (market research), sequentialthinking (reasoning)

## Key Patterns
- Socratic Dialogue → systematic requirements discovery
- Multi-Domain Analysis → comprehensive feasibility assessment
- Progressive Coordination → iterative refinement
- Specification Generation → actionable implementation briefs

## Examples
```bash
/sc:brainstorm "AI-powered project management tool" --strategy systematic --depth deep
/sc:brainstorm "real-time collaboration features" --strategy agile --parallel
/sc:brainstorm "enterprise data analytics platform" --strategy enterprise --validate
/sc:brainstorm "mobile app monetization strategy" --depth normal
```

## CRITICAL BOUNDARIES

**STOP AFTER REQUIREMENTS DISCOVERY** — This produces a REQUIREMENTS SPECIFICATION ONLY.

**Will NOT**: Create architecture diagrams (`/sc:design`), generate code (`/sc:implement`), make architectural decisions, design DB schemas/API contracts.

**Output**: Requirements document with clarified goals, functional/non-functional requirements, user stories/acceptance criteria, open questions.

**Next Step**: Use `/sc:design` for architecture or `/sc:workflow` for implementation planning.
