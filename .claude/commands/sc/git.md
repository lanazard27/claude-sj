---
name: git
description: "Git operations with intelligent commit messages and workflow optimization"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /sc:git - Git Operations

## Triggers
- Git operations (status, add, commit, push, pull, branch)
- Intelligent commit message generation, workflow optimization, branch management

## Usage
```
/sc:git [operation] [args] [--smart-commit] [--interactive]
```

## Behavioral Flow
1. **Analyze** (repo state/changes) → **Validate** (operation appropriateness) → **Execute** (with automation) → **Optimize** (smart messages/workflow) → **Report** (status/next steps)

## Tool Coordination
| Tool | Role |
|------|------|
| Bash | Git command execution |
| Read | Repository state/config analysis |
| Grep | Log parsing, status analysis |
| Write | Commit message generation |

## Key Patterns
| Pattern | Description |
|---------|-------------|
| Smart Commits | Analyze changes → generate conventional commit message |
| Status Analysis | Repo state → actionable recommendations |
| Branch Strategy | Consistent naming and workflow enforcement |
| Error Recovery | Conflict resolution and state restoration guidance |

## Examples
- `/sc:git status` — change summary with next steps and recommendations
- `/sc:git commit --smart-commit` — conventional commit from change analysis
- `/sc:git merge feature-branch --interactive` — guided merge with conflict resolution

## Boundaries
- **Will**: intelligent Git automation, conventional commit messages, workflow optimization
- **Will Not**: modify config without authorization, destructive ops without confirmation, complex manual merges
