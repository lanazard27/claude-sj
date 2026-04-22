#!/bin/bash
# ~/.claude/hooks/on-stop.sh
# Stop hook — 메인 에이전트 응답 완료 시 메모리 체크 + 세션 자동 저장
# exit 0 = 정상, exit 2 = Claude에게 피드백 전달

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"

# ============================================================
# MEMORY.md 크기 체크 (150줄 초과 시 경고)
# ============================================================
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
  LINE_COUNT=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [ "$LINE_COUNT" -gt 150 ]; then
    echo "[memory-warning] MEMORY.md가 ${LINE_COUNT}줄입니다 (제한 200). 세션 종료 시 자동 압축됩니다." >&2
  fi
fi

# ============================================================
# 세션 상태 자동 저장 (compact/crash 대비)
# ============================================================
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/audit-$(date +%Y-%m-%d).log"
SESSIONS_DIR="$PROJECT_DIR/.claude/sessions"
SAVE_SCRIPT="$PROJECT_DIR/.claude/scripts/save-session.py"

# 세션 ID는 stdin에서 추출
INPUT=$(cat 2>/dev/null || echo "")
SESSION_ID=""
if [ -n "$INPUT" ]; then
  SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")
fi

if [ -f "$SAVE_SCRIPT" ] && [ -n "$SESSION_ID" ]; then
  python3 "$SAVE_SCRIPT" "$PROJECT_DIR" "$SESSIONS_DIR" "$SESSION_ID" "$LOG_FILE" 2>/dev/null
fi

exit 0
