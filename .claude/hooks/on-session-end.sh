#!/bin/bash
# ~/.claude/hooks/on-session-end.sh
# SessionEnd hook — 세션 종료 시 정리 작업
# stdout: Claude에게 전달되지 않음 (세션 이미 종료됨)
# 주요 역할: 감사 로그, 임시 파일 정리, 메모리 자동 최적화

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/audit-$(date +%Y-%m-%d).log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

INPUT=$(cat 2>/dev/null || echo "")
SESSION_ID=""

if [ -n "$INPUT" ]; then
  SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")
fi

# 세션 종료 로그 기록
echo "[$TIMESTAMP] session=$SESSION_ID event=SESSION_END" >> "$LOG_FILE"

# ============================================================
# 1. 오래된 로그 정리 (30일)
# ============================================================
find "$LOG_DIR" -name "audit-*.log" -mtime +30 -delete 2>/dev/null || true

# 오래된 보안 상태 파일 정리
STATE_DIR="$HOME/.claude/security-state"
if [ -d "$STATE_DIR" ]; then
  find "$STATE_DIR" -name "warnings-*.json" -mtime +30 -delete 2>/dev/null || true
fi

# ============================================================
# 2. 메모리 자동 최적화
# ============================================================
OPTIMIZE_SCRIPT="$PROJECT_DIR/.claude/scripts/memory-optimize.sh"
if [ -f "$OPTIMIZE_SCRIPT" ]; then
  OPTIMIZE_RESULT=$(bash "$OPTIMIZE_SCRIPT" 2>/dev/null || echo "")
  if [ "$OPTIMIZE_RESULT" = "memory-optimized" ]; then
    echo "[$TIMESTAMP] session=$SESSION_ID event=MEMORY_OPTIMIZED" >> "$LOG_FILE"
  fi
fi

# ============================================================
# 3. 오래된 통계 정리 (stats-tracker가 누락 시 대비)
# ============================================================
STATS_DIR="$MEMORY_DIR/../stats"
if [ -d "$STATS_DIR" ]; then
  find "$STATS_DIR" -name "usage.json" -mtime +30 -delete 2>/dev/null || true
fi

# ============================================================
# 4. 세션 상태 자동 저장 (latest.md)
# ============================================================
SESSIONS_DIR="$PROJECT_DIR/.claude/sessions"
SAVE_SCRIPT="$PROJECT_DIR/.claude/scripts/save-session.py"

if [ -f "$SAVE_SCRIPT" ]; then
  SAVE_RESULT=$(python3 "$SAVE_SCRIPT" "$PROJECT_DIR" "$SESSIONS_DIR" "$SESSION_ID" "$LOG_FILE" 2>/dev/null || echo "")
  if [ "$SAVE_RESULT" = "SESSION_SAVED" ]; then
    echo "[$TIMESTAMP] session=$SESSION_ID event=SESSION_SAVED" >> "$LOG_FILE"
  fi
fi

exit 0
