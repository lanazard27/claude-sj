---
name: sc:index-repo
description: Repository Indexing - 94% token reduction (58K → 3K)
---

# Repository Index Creator

## Problem Statement
**Before**: Reading all files → 58,000 tokens | **After**: Read PROJECT_INDEX.md → 3,000 tokens (94% reduction)

## Index Creation Flow

### Phase 1: Analyze Repository Structure (5 concurrent Glob searches)
1. **Code**: `src/**/*.{ts,py,js,tsx,jsx}`, `lib/**/*.{ts,py,js}`, `superclaude/**/*.py`
2. **Docs**: `docs/**/*.md`, `*.md` (root), `README*.md`
3. **Config**: `*.toml`, `*.yaml`, `*.yml`, `*.json` (exclude package-lock, node_modules)
4. **Tests**: `tests/**/*.{py,ts,js}`, `**/*.test.{ts,py,js}`, `**/*.spec.{ts,py,js}`
5. **Scripts**: `scripts/**/*`, `bin/**/*`, `tools/**/*`

### Phase 2: Extract Metadata
For each category: entry points (main.py, index.ts, cli.py), key modules/exports, API surface, dependencies

### Phase 3: Generate Index (PROJECT_INDEX.md)
```markdown
# Project Index: {project_name}
Generated: {timestamp}

## Project Structure: {tree view}
## Entry Points: CLI, API, Tests with paths and descriptions
## Core Modules: path, exports, purpose per module
## Configuration: config files and purposes
## Documentation: doc files and topics
## Test Coverage: unit/integration counts, coverage %
## Key Dependencies: dependency, version, purpose
## Quick Start: setup, run, test steps
```

### Phase 4: Validation
- [ ] All entry points identified
- [ ] Core modules documented
- [ ] Index size < 5KB
- [ ] Human-readable format

## Usage
```
/index-repo              # Create index
/index-repo mode=update  # Update existing
/index-repo mode=quick   # Skip tests
```

## Token Efficiency
- Index creation: 2,000 tokens (one-time)
- Index reading: 3,000 tokens (every session)
- Full codebase: 58,000 tokens (every session)
- Break-even: 1 session | 10 sessions: 550K saved | 100 sessions: 5.5M saved

## Output
1. `PROJECT_INDEX.md` (3KB, human-readable)
2. `PROJECT_INDEX.json` (10KB, machine-readable)
