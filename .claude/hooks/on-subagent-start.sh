#!/bin/bash
# SubagentStart: 에이전트 시작 로깅
LOG_FILE="/Users/jeongsunjae/projects/claude-sj/.claude/logs/agent-start.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "$(date '+%Y-%m-%d %H:%M:%S') | subagent_started" >> "$LOG_FILE"

# 로그 30일 이상 된 것 정리
if [ -f "$LOG_FILE" ]; then
  find "$(dirname "$LOG_FILE")" -name "*.log" -mtime +30 -delete 2>/dev/null
fi

exit 0
