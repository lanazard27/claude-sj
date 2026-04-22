#!/bin/bash
# PreCompact: compact 전 세션 상태 백업
SESSION_FILE="/Users/jeongsunjae/projects/claude-sj/.claude/sessions/latest.md"
BACKUP_FILE="/Users/jeongsunjae/projects/claude-sj/.claude/sessions/latest-pre-compact.md"

if [ -f "$SESSION_FILE" ]; then
  cp "$SESSION_FILE" "$BACKUP_FILE"
fi

exit 0
