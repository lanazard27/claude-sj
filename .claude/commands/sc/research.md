---
name: research
description: Deep web research with adaptive planning and intelligent search
category: command
complexity: advanced
mcp-servers: [tavily, sequential, playwright, serena]
personas: [deep-research-agent]
---

# /sc:research - Deep Research Command

## Triggers
Research beyond knowledge cutoff, complex questions, current events, academic/technical research, market analysis.

## Usage
```
/sc:research "[query]" [--depth quick|standard|deep|exhaustive] [--strategy planning|intent|unified]
```

## Behavioral Flow

| Phase | Effort | Actions |
|-------|--------|---------|
| 1. Understand | 5-10% | Assess complexity, identify info types, define success criteria |
| 2. Plan | 10-15% | Select strategy, identify parallelization, decompose questions, set milestones |
| 3. TodoWrite | 5% | Create adaptive task hierarchy (3-15 tasks), set dependencies, track progress |
| 4. Execute | 50-60% | Parallel-first searches, smart extraction, multi-hop exploration, evidence collection |
| 5. Track | Continuous | Monitor progress, update confidence, log patterns, identify gaps |
| 6. Validate | 10-15% | Verify evidence chains, check credibility, resolve contradictions, ensure completeness |

## Key Patterns
- **Parallel Execution**: Batch independent searches, concurrent extractions, sequential only for dependencies
- **Evidence Management**: Track results, provide citations, note uncertainties
- **Adaptive Depth**: Quick (1 hop, summary) | Standard (2-3 hops, structured report) | Deep (3-4 hops, detailed analysis) | Exhaustive (5 hops, complete investigation)

## MCP Integration
- **Tavily**: Primary search and extraction
- **Sequential**: Complex reasoning and synthesis
- **Playwright**: JS-heavy content extraction
- **Serena**: Research session persistence

## Output
Save to `claudedocs/research_[topic]_[timestamp].md` with executive summary, confidence levels, cited sources.

## CRITICAL BOUNDARIES

**STOP AFTER RESEARCH REPORT** — This produces a RESEARCH REPORT ONLY, no implementation.

**Will NOT**: Implement findings, write code, make architectural decisions, create system changes.

**Output**: Research report with findings, evidence-based analysis, recommendations (for human decision), cited references.

**Next Step**: User decides. Use `/sc:design` for architecture or `/sc:implement` for coding.
