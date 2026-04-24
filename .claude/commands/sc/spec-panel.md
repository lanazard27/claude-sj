---
name: spec-panel
description: "Multi-expert specification review and improvement using renowned specification and software engineering experts"
category: analysis
complexity: enhanced
mcp-servers: [sequential, context7]
personas: [technical-writer, system-architect, quality-engineer]
---

# /sc:spec-panel - Expert Specification Review Panel

## Usage
```
/sc:spec-panel [specification_content|@file] [--mode discussion|critique|socratic] [--experts "name1,name2"] [--focus requirements|architecture|testing|compliance] [--iterations N] [--format standard|structured|detailed]
```

## Behavioral Flow
1. **Analyze**: Parse specification, identify key components, gaps, quality issues
2. **Assemble**: Select expert panel based on specification type and focus
3. **Review**: Multi-expert analysis using distinct methodologies
4. **Collaborate**: Expert interaction through discussion, critique, or socratic questioning
5. **Synthesize**: Consolidated findings with prioritized recommendations
6. **Improve**: Enhanced specification incorporating expert feedback

## Expert Panel System

### Core Specification Experts

| Expert | Domain | Methodology | Critique Focus |
|--------|--------|-------------|----------------|
| **Karl Wiegers** | Functional/non-functional requirements | SMART criteria, testability analysis, stakeholder validation | "Lacks measurable acceptance criteria. How validate compliance?" |
| **Gojko Adzic** | Behavior-driven specs, living documentation | Given/When/Then scenarios, example-driven requirements | "Can you provide concrete examples demonstrating this?" |
| **Alistair Cockburn** | Use case methodology, agile requirements | Goal-oriented analysis, primary actor identification, scenario modeling | "Who is the primary stakeholder? What business goal?" |

### Technical Architecture Experts

| Expert | Domain | Methodology | Critique Focus |
|--------|--------|-------------|----------------|
| **Martin Fowler** | API design, system architecture, design patterns | Interface segregation, bounded contexts, refactoring patterns | "This violates SRP. Consider separating concerns." |
| **Michael Nygard** | Production systems, reliability, failure modes | Failure mode analysis, circuit breaker patterns | "What happens when this fails? Where are monitoring/recovery?" |
| **Sam Newman** | Microservices, service boundaries, API evolution | Service decomposition, API versioning | "How does this handle service evolution and backward compatibility?" |
| **Gregor Hohpe** | Messaging patterns, system integration | Message-driven architecture, event-driven design | "What's the message exchange pattern? Ordering/delivery guarantees?" |

### Quality & Testing Experts

| Expert | Domain | Methodology | Critique Focus |
|--------|--------|-------------|----------------|
| **Lisa Crispin** | Testing strategies, quality requirements | Whole-team testing, risk-based testing | "How would testing team validate this? Edge cases?" |
| **Janet Gregory** | Collaborative testing, specification workshops | Specification workshops, three amigos | "Did whole team participate? Are quality expectations clear?" |

### Modern Software Experts

| Expert | Domain | Methodology | Critique Focus |
|--------|--------|-------------|----------------|
| **Kelsey Hightower** | Kubernetes, cloud architecture, IaC | Cloud-native patterns, operational observability | "How does this handle cloud-native deployment concerns?" |

## MCP Integration
- **Sequential MCP**: Primary engine for expert panel coordination and iterative improvement
- **Context7 MCP**: Auto-activated for specification patterns and industry best practices
- **Personas**: Technical Writer (writing quality), System Architect (architectural analysis), Quality Engineer (testing strategy)

## Analysis Modes

### Discussion Mode (`--mode discussion`)
Collaborative improvement through sequential expert commentary building upon previous insights.

```
Example:
WIEGERS: "Requirement 'SHALL handle failures gracefully' lacks specificity."
NYGARD: "Need specific failure modes: timeouts, unavailable, rate limiting."
ADZIC: "Given: Service timeout after 30s → When: Circuit breaker activates → Then: Return cached response within 100ms"
FOWLER: "Should also define failure notification interface."
```

### Critique Mode (`--mode critique`)
Systematic review with severity classification, specific recommendations, priority ranking, quality metrics.

```
Example:
WIEGERS - Requirements Quality:
❌ CRITICAL: R-001 lacks measurable acceptance criteria
📝 RECOMMENDATION: Replace "handle failures gracefully" with "open circuit breaker after 5 consecutive failures within 30s"
🎯 PRIORITY: High | 📊 IMPACT: +40% testability, +60% clarity
```

### Socratic Mode (`--mode socratic`)
Learning-focused questioning: foundational understanding, stakeholder clarification, assumption identification, alternative exploration.

## Focus Areas

| Focus | Expert Panel | Analysis Areas |
|-------|-------------|----------------|
| `requirements` | Wiegers (lead), Adzic, Cockburn | Clarity, completeness, testability, acceptance criteria, traceability |
| `architecture` | Fowler (lead), Newman, Hohpe, Nygard | Interface design, system boundaries, scalability, design patterns, integration |
| `testing` | Crispin (lead), Gregory, Adzic | Test strategy, coverage, edge cases, acceptance criteria, automation |
| `compliance` | Wiegers (lead), Nygard, Hightower | Regulatory coverage, security specs, observability, audit trail, risk assessment |

## Tool Coordination
- **Read**: Specification content analysis
- **Sequential**: Expert panel coordination and iterative analysis
- **Context7**: Specification patterns and best practices
- **Grep**: Cross-reference validation
- **Write**: Improved specification generation
- **MultiEdit**: Collaborative specification enhancement

## Iterative Improvement Process

### Single Iteration (Default)
Initial Analysis → Issue Identification → Improvement Recommendations → Priority Ranking

### Multi-Iteration (`--iterations N`)
| Iteration | Focus |
|-----------|-------|
| 1 | Structural/fundamental: requirements clarity, architecture consistency, major gaps |
| 2 | Detail refinement: specific improvements, edge cases, quality attributes |
| 3 | Polish: documentation quality, example enhancement, final validation |

## Output Formats

### Standard (`--format standard`)
```yaml
specification_review:
  original_spec: "file.yml"
  expert_panel: ["wiegers", "adzic", "nygard", "fowler"]
  quality_assessment: { overall: 7.2/10, requirements: 8.1, architecture: 6.8, testability: 7.5 }
  critical_issues: [{ category, severity, expert, issue, recommendation }]
  expert_consensus: ["key agreements"]
  improvement_roadmap: { immediate: [], short_term: [], long_term: [] }
```

### Structured (`--format structured`)
Token-efficient format using symbol system.

### Detailed (`--format detailed`)
Comprehensive analysis with full expert commentary and implementation guidance.

## Examples
```bash
/sc:spec-panel @auth_api.spec.yml --mode critique --focus requirements,architecture
/sc:spec-panel "user story content" --mode discussion --experts "wiegers,adzic,cockburn"
/sc:spec-panel @microservice.spec.yml --mode socratic --focus architecture
/sc:spec-panel @complex_system.spec.yml --iterations 3 --format detailed
/sc:spec-panel @security_requirements.yml --focus compliance --experts "wiegers,nygard"
```

## Integration Patterns
```bash
# Generate spec from code → review → refine
/sc:code-to-spec ./authentication_service --type api --format yaml
/sc:spec-panel @generated_auth_spec.yml --mode critique --focus requirements,testing
/sc:spec-panel @improved_auth_spec.yml --mode discussion --iterations 2
```

## Quality Metrics
- **Clarity Score**: Language precision (0-10)
- **Completeness Score**: Coverage of essential elements (0-10)
- **Testability Score**: Measurability and validation capability (0-10)
- **Consistency Score**: Internal coherence and contradiction detection (0-10)

## Boundaries

**Will:**
- Expert-level specification review with actionable recommendations and priority rankings
- Multiple analysis modes for different use cases
- Integration with specification generation tools

**Will Not:**
- Replace human judgment in critical decisions
- Modify specs without explicit user consent
- Generate specs from scratch without existing content
- Provide legal/compliance guarantees beyond analysis

**Output**: Expert review document with multi-expert analysis, recommendations, consensus/disagreements, priority-ranked improvements.

**Next Step**: Incorporate feedback, then use `/sc:design` for architecture or `/sc:implement` for coding.
