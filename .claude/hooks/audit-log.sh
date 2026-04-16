#!/bin/bash
# ~/.claude/hooks/audit-log.sh
# PostToolUse hook — 모든 도구 사용을 날짜별 로그로 기록
# 입력: stdin으로 JSON 전달 (tool_name, tool_input, session_id 등 포함)
#
# v2: python3 서브프로세스 5회 → 1회로 최적화 (성능 개선)
# 기록 항목:
# - 타임스탬프, 세션 ID, 도구명
# - 파일 경로 (Write/Edit 시)
# - Bash 명령어 (Bash 시)
# - 도구 입력 요약

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/audit-$(date +%Y-%m-%d).log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# stdin을 변수에 저장 (한 번만 읽기 가능)
INPUT=$(cat 2>/dev/null || echo "")

if [ -n "$INPUT" ]; then
  # 단일 python3 호출로 모든 필드 한 번에 추출 (성능 최적화)
  eval "$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    tool = d.get('tool_name', 'unknown')
    ti = d.get('tool_input', {})
    fp = ti.get('file_path', '')
    cmd = ti.get('command', '')
    sid = d.get('session_id', '')
    agent = d.get('agent_name', d.get('agent_type', '')) or 'sj'
    subagent = ti.get('subagent_type', '') if tool == 'Agent' else ''
    # 안전한 출력 (값에 공백/특수문자 있으면 quoted 출력)
    print(f'TOOL={tool!r}')
    print(f'FILE_PATH={fp!r}')
    print(f'COMMAND={cmd[:200]!r}')
    print(f'SESSION_ID={sid!r}')
    print(f'AGENT={agent!r}')
    print(f'SUBAGENT_TYPE={subagent!r}')
except Exception:
    print('TOOL=\"unknown\"')
    print('FILE_PATH=\"\"')
    print('COMMAND=\"\"')
    print('SESSION_ID=\"\"')
    print('AGENT=\"sj\"')
    print('SUBAGENT_TYPE=\"\"')
" 2>/dev/null)" || {
    TOOL="unknown"
    FILE_PATH=""
    COMMAND=""
    SESSION_ID=""
    AGENT="sj"
    SUBAGENT_TYPE=""
}
else
  TOOL="unknown"
  FILE_PATH=""
  COMMAND=""
  SESSION_ID=""
  AGENT="sj"
  SUBAGENT_TYPE=""
fi

# 로그 기록 (구조화된 형식 — 에이전트 식별자 + subagent_type 포함)
if [ -n "$SUBAGENT_TYPE" ]; then
  if [ -n "$FILE_PATH" ]; then
    echo "[$TIMESTAMP] session=$SESSION_ID agent=$AGENT tool=$TOOL subagent=$SUBAGENT_TYPE file=$FILE_PATH" >> "$LOG_FILE"
  elif [ -n "$COMMAND" ]; then
    echo "[$TIMESTAMP] session=$SESSION_ID agent=$AGENT tool=$TOOL subagent=$SUBAGENT_TYPE cmd=$COMMAND" >> "$LOG_FILE"
  else
    echo "[$TIMESTAMP] session=$SESSION_ID agent=$AGENT tool=$TOOL subagent=$SUBAGENT_TYPE" >> "$LOG_FILE"
  fi
else
  if [ -n "$FILE_PATH" ]; then
    echo "[$TIMESTAMP] session=$SESSION_ID agent=$AGENT tool=$TOOL file=$FILE_PATH" >> "$LOG_FILE"
  elif [ -n "$COMMAND" ]; then
    echo "[$TIMESTAMP] session=$SESSION_ID agent=$AGENT tool=$TOOL cmd=$COMMAND" >> "$LOG_FILE"
  else
    echo "[$TIMESTAMP] session=$SESSION_ID agent=$AGENT tool=$TOOL" >> "$LOG_FILE"
  fi
fi

# ============================================================
# 로그 로테이션 — 30일 이상 된 로그 자동 삭제 (10% 확률로 실행)
# ============================================================
if [ $((RANDOM % 10)) -eq 0 ]; then
  find "$LOG_DIR" -name "audit-*.log" -mtime +30 -delete 2>/dev/null || true
fi

exit 0
