#!/bin/bash
# ~/.claude/hooks/on-subagent-stop.sh
# SubagentStop hook — 서브에이전트 완료 시 감사 로그 기록
# stdout: Claude에게 피드백 전달 가능 (에이전트 결과 품질 표시)

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/audit-$(date +%Y-%m-%d).log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

INPUT=$(cat 2>/dev/null || echo "")
SESSION_ID=""

if [ -n "$INPUT" ]; then
  SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")
fi

# 서브에이전트 완료 로그 기록
echo "[$TIMESTAMP] session=$SESSION_ID event=SUBAGENT_STOP" >> "$LOG_FILE"

# stdout은 Claude에게 전달 — 서브에이전트 결과 검증 리마인드
echo "[agent-done] 결과 검증 필요"

exit 0
