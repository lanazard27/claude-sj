---
command: "/sc:business-panel"
category: "Analysis & Strategic Planning"
purpose: "Multi-expert business analysis with adaptive interaction modes"
wave-enabled: true
performance-profile: "complex"
---

# /sc:business-panel - Business Panel Analysis System

## Overview
AI-facilitated panel discussion between renowned business thought leaders analyzing documents through distinct frameworks.

## Expert Panel

| Expert | Specialization |
|--------|---------------|
| **Clayton Christensen** | Disruption Theory, Jobs-to-be-Done |
| **Michael Porter** | Competitive Strategy, Five Forces |
| **Peter Drucker** | Management Philosophy, MBO |
| **Seth Godin** | Marketing Innovation, Tribe Building |
| **W. Chan Kim & Renee Mauborgne** | Blue Ocean Strategy |
| **Jim Collins** | Organizational Excellence, Good to Great |
| **Nassim Nicholas Taleb** | Risk Management, Antifragility |
| **Donella Meadows** | Systems Thinking, Leverage Points |
| **Jean-luc Doumont** | Communication Systems, Structured Clarity |

## Analysis Modes

| Phase | Mode | Description |
|-------|------|-------------|
| 1 (Default) | **DISCUSSION** | Collaborative analysis — experts build upon each other's insights |
| 2 | **DEBATE** | Adversarial analysis — activated when experts disagree or for controversial topics |
| 3 | **SOCRATIC** | Question-driven exploration for deep learning and strategic thinking |

## Usage

```bash
# Basic
/sc:business-panel [document_path_or_content]

# Advanced
/sc:business-panel [content] --experts "porter,christensen,meadows"
/sc:business-panel [content] --mode debate
/sc:business-panel [content] --focus "competitive-analysis"
/sc:business-panel [content] --synthesis-only
```

### Options
| Flag | Purpose |
|------|---------|
| `--mode discussion\|debate\|socratic\|adaptive` | Analysis mode selection |
| `--experts "name1,name2,name3"` | Select specific experts |
| `--focus domain` | Auto-select experts for domain |
| `--all-experts` | Include all 9 experts |
| `--synthesis-only` | Skip detailed analysis, show synthesis |
| `--structured` | Symbol system for efficiency |
| `--verbose` | Full detailed analysis |
| `--questions` | Focus on strategic questions |

## Auto-Persona Activation
- **Auto-Activates**: Analyzer, Architect, Mentor personas
- **MCP**: Sequential (primary), Context7 (business patterns)
- **Tools**: Read, Grep, Write, MultiEdit, TodoWrite

## Integration
- Compatible with --think, --think-hard, --ultrathink
- Supports wave orchestration
- Integrates with scribe persona

## CRITICAL BOUNDARIES

**SYNTHESIS OUTPUT ONLY — NOT IMPLEMENTATION**

**Default**: Assemble panel → conduct analysis → **STOP with synthesis document**

**Will NOT**: Implement recommendations, make code/architectural changes, execute decisions without approval.

**Output**: Business analysis with expert perspectives (9 experts), consensus points, disagreements, priority-ranked recommendations.

**Next Step**: Use `/sc:design` (architecture), `/sc:implement` (features), or `/sc:workflow` (planning).
