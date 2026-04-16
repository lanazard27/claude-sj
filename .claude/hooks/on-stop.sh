#!/bin/bash
# ~/.claude/hooks/on-stop.sh
# Stop hook — 메인 에이전트 응답 완료 시 WIP 상태 자동 업데이트
# stdin: JSON with session_id, transcript, stop_hook_active
# exit 0 = 정상, exit 2 = Claude에게 피드백 전달

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"
WIP_FILE="$MEMORY_DIR/work-in-progress.md"

# WIP 파일이 없으면 종료
if [ ! -f "$WIP_FILE" ]; then
  exit 0
fi

# 현재 WIP 상태 확인
WIP_STATUS=$(grep -A 1 "^- \*\*상태\*\*" "$WIP_FILE" 2>/dev/null | head -1 | sed 's/^- \*\*상태\*\*: //' || echo "")

# 진행 중인 작업이 없으면 종료
if [ -z "$WIP_STATUS" ] || [ "$WIP_STATUS" = "없음" ]; then
  exit 0
fi

# 마지막 업데이트 시간 기록
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# WIP 파일에 마지막 활동 시간 업데이트
if grep -q "마지막 활동" "$WIP_FILE" 2>/dev/null; then
  sed -i '' "s/^- \*\*마지막 활동\*\*:.*$/- **마지막 활동**: ${TIMESTAMP}/" "$WIP_FILE" 2>/dev/null
else
  sed -i '' "/^- \*\*상태\*\*:/a\\
- **마지막 활동**: ${TIMESTAMP}" "$WIP_FILE" 2>/dev/null
fi

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
