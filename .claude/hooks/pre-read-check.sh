#!/bin/bash
# ~/.claude/hooks/pre-read-check.sh
# PreToolUse hook for Read — 민감 파일 읽기 차단
# permissions.deny가 작동하지 않는 문제를 훅으로 보완.
# 공통 로직은 lib/sensitive-files.sh에 정의

HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/lib/sensitive-files.sh"

INPUT=$(cat 2>/dev/null || echo "")
[ -z "$INPUT" ] && exit 0

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

check_sensitive "$FILE_PATH" "읽기"
exit $?
