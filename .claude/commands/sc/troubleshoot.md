---
name: troubleshoot
description: "Diagnose and resolve issues in code, builds, deployments, and system behavior"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /sc:troubleshoot - Issue Diagnosis and Resolution

## Triggers
Code defects, build failures, performance issues, deployment problems.

## Usage
```
/sc:troubleshoot [issue] [--type bug|build|performance|deployment] [--trace] [--fix]
```

## Behavioral Flow
1. **Analyze**: Examine issue, gather system state
2. **Investigate**: Root cause through systematic pattern analysis
3. **Debug**: Structured debugging (logs, state examination)
4. **Propose**: Solution approaches with impact assessment
5. **Resolve**: Apply fixes, verify resolution

Key behaviors: Root cause analysis with hypothesis testing, multi-domain troubleshooting (code/build/performance/deployment), structured debugging, safe fix with verification.

## Tool Coordination
- **Read**: Log analysis and state examination
- **Bash**: Diagnostic command execution
- **Grep**: Error pattern detection
- **Write**: Diagnostic reports

## Key Patterns
- **Bug**: Error analysis → stack trace → code inspection → fix validation
- **Build**: Build log → dependency check → config validation
- **Performance**: Metrics → bottleneck ID → optimization recommendations
- **Deployment**: Environment → config verification → service validation

## Examples
```bash
/sc:troubleshoot "Null pointer exception in user service" --type bug --trace
/sc:troubleshoot "TypeScript compilation errors" --type build --fix
/sc:troubleshoot "API response times degraded" --type performance
/sc:troubleshoot "Service not starting in production" --type deployment --trace
```

## CRITICAL BOUNDARIES

**DIAGNOSE FIRST — FIXES REQUIRE `--fix` FLAG**

**Default (no `--fix`)**: Diagnose → identify root cause → propose solutions → **STOP** (no fixes applied)

**With `--fix`**: After diagnosis → prompt user confirmation → apply fix → verify with tests

**Will NOT without `--fix`**: Apply code changes, modify files, execute fixes automatically.

**Output**: Diagnostic report with issue description, root cause analysis, proposed solutions (ranked), risk assessment.

**Next Step**: Re-run with `--fix` to apply, or use `/sc:improve` for broader refactoring.
