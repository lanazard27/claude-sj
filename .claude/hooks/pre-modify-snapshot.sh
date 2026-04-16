#!/bin/bash
# pre-modify-snapshot.sh — 파일 수정 전 자동 스냅샷 생성 (롤백 가능)
# PreToolUse hook for Write|Edit — 수정 전 원본 보존
# exit 0 = 허용, exit 2 = 차단

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"

INPUT=$(cat 2>/dev/null || echo "")
[ -z "$INPUT" ] && exit 0

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

# 신규 파일은 스냅샷 불필요
[ ! -f "$FILE_PATH" ] && exit 0

# .claude/ 내 파일은 시스템 설정 → 스냅샷 불필요
echo "$FILE_PATH" | grep -q "/\.claude/" && exit 0

# memory/ 내 파일도 스냅샷 불필요
echo "$FILE_PATH" | grep -q "memory/" && exit 0

SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id','default'))" 2>/dev/null || echo "default")

SNAPSHOT_DIR="$MEMORY_DIR/snapshots/${SESSION_ID}"
mkdir -p "$SNAPSHOT_DIR"

# 상대 경로 → 스냅샷 파일명
REL_PATH=$(echo "$FILE_PATH" | sed "s|^$PROJECT_DIR/||")
SNAPSHOT_NAME=$(echo "$REL_PATH" | tr '/' '_')

# 최초 상태만 보존 (이미 있으면 덮어쓰지 않음 — 수정 전 원본 유지)
SNAPSHOT_FILE="$SNAPSHOT_DIR/$SNAPSHOT_NAME"
if [ ! -f "$SNAPSHOT_FILE" ]; then
  cp "$FILE_PATH" "$SNAPSHOT_FILE" 2>/dev/null
fi

exit 0
