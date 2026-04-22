#!/bin/bash
# ~/.claude/hooks/on-stop.sh
# Stop hook — 메인 에이전트 응답 완료 시 메모리 상태 체크
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

exit 0
