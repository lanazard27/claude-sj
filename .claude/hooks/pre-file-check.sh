#!/bin/bash
# ~/.claude/hooks/pre-file-check.sh
# PreToolUse hook for Write|Edit — 민감 파일 쓰기/수정 차단
# 공통 로직은 lib/sensitive-files.sh에 정의

HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/lib/sensitive-files.sh"

INPUT=$(cat 2>/dev/null || echo "")
[ -z "$INPUT" ] && exit 0

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

check_sensitive "$FILE_PATH" "쓰기/수정"
exit $?
