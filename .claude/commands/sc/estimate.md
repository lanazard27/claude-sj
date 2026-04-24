---
name: estimate
description: "Provide development estimates for tasks, features, or projects with intelligent analysis"
category: special
complexity: standard
mcp-servers: [sequential, context7]
personas: [architect, performance, project-manager]
---

# /sc:estimate - Development Estimation

## Triggers
Development planning, project scoping, feature breakdown, risk assessment.

## Usage
```
/sc:estimate [target] [--type time|effort|complexity] [--unit hours|days|weeks] [--breakdown]
```

## Behavioral Flow
1. **Analyze**: Examine scope, complexity factors, dependencies, framework patterns
2. **Calculate**: Apply estimation with historical benchmarks and complexity scoring
3. **Validate**: Cross-reference with project patterns and domain expertise
4. **Present**: Detailed breakdown with confidence intervals and risk assessment
5. **Track**: Document estimation accuracy for improvement

Key behaviors: Multi-persona (architect, performance, PM), Sequential for systematic analysis, Context7 for framework benchmarks, intelligent breakdown with confidence intervals.

## MCP Integration
- **Sequential**: Complex estimation analysis and complexity assessment
- **Context7**: Framework-specific patterns and historical benchmarks
- **Personas**: Architect (design complexity), Performance (optimization effort), PM (timeline)

## Tool Coordination
Read/Grep/Glob (complexity assessment), TodoWrite (estimation breakdown), Task (multi-domain estimation), Bash (project analysis)

## Key Patterns
- Scope Analysis: Requirements → complexity → patterns → risk
- Methodology: Time | Effort | Complexity | Cost approaches
- Multi-Domain: Architecture → Performance → Timeline
- Validation: Benchmarks → cross-validation → confidence intervals → tracking

## Examples
```bash
/sc:estimate "user authentication system" --type time --unit days --breakdown
/sc:estimate "migrate monolith to microservices" --type complexity --breakdown
/sc:estimate "optimize application performance" --type effort --unit hours
```

## CRITICAL BOUNDARIES

**STOP AFTER ESTIMATION** — This produces an ESTIMATION REPORT ONLY, no implementation.

**Will NOT**: Execute work, create timelines for execution, start tasks, make commitments.

**Output**: Estimation report with time/effort breakdown, complexity analysis, confidence intervals, risk assessment, resource requirements.

**Next Step**: User decides timeline. Use `/sc:workflow` for planning or `/sc:implement` for execution.
