#!/bin/bash
# ~/.claude/hooks/audit-log.sh
# PostToolUse hook — 감사 로그 + 통계 누적 (통합 버전)
# 입력: stdin으로 JSON 전달 (tool_name, tool_input, session_id 등 포함)

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/audit-$(date +%Y-%m-%d).log"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
STATS_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/stats"
mkdir -p "$STATS_DIR"
STATS_FILE="$STATS_DIR/usage.json"

INPUT=$(cat 2>/dev/null || echo "")
[ -z "$INPUT" ] && exit 0

# 단일 python3 호출로 감사 로그 + 통계 누적 동시 처리
echo "$INPUT" | python3 -c "
import sys, json, os
from datetime import datetime, timedelta

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool = d.get('tool_name', 'unknown')
ti = d.get('tool_input', {})
fp = ti.get('file_path', '')
cmd = ti.get('command', '')[:200]
sid = d.get('session_id', '')
agent = d.get('agent_name', d.get('agent_type', '')) or 'sj'
subagent = ti.get('subagent_type', '') if tool == 'Agent' else ''
ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# --- 감사 로그 ---
if subagent:
    detail = f'subagent={subagent}'
    if fp: detail += f' file={fp}'
    elif cmd: detail += f' cmd={cmd}'
    log_line = f'[{ts}] session={sid} agent={agent} tool={tool} {detail}'
else:
    if fp: log_line = f'[{ts}] session={sid} agent={agent} tool={tool} file={fp}'
    elif cmd: log_line = f'[{ts}] session={sid} agent={agent} tool={tool} cmd={cmd}'
    else: log_line = f'[{ts}] session={sid} agent={agent} tool={tool}'

with open('$LOG_FILE', 'a') as f:
    f.write(log_line + '\n')

# --- 통계 누적 ---
stats = {}
if os.path.exists('$STATS_FILE'):
    try:
        with open('$STATS_FILE') as f:
            stats = json.load(f)
    except Exception:
        pass

today = datetime.now().strftime('%Y-%m-%d')
if today not in stats:
    stats[today] = {'tools': {}, 'agents': {}, 'subagents': {}, 'files_modified': 0, 'sessions': []}

if sid and sid not in stats[today]['sessions']:
    stats[today]['sessions'].append(sid)
stats[today]['tools'][tool] = stats[today]['tools'].get(tool, 0) + 1
stats[today]['agents'][agent] = stats[today]['agents'].get(agent, 0) + 1
if subagent:
    stats[today]['subagents'][subagent] = stats[today]['subagents'].get(subagent, 0) + 1
if tool in ('Write', 'Edit'):
    stats[today]['files_modified'] = stats[today].get('files_modified', 0) + 1

# 30일 이전 데이터 정리
cutoff = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
for k in list(stats.keys()):
    if k < cutoff:
        del stats[k]

with open('$STATS_FILE', 'w') as f:
    json.dump(stats, f, indent=2, ensure_ascii=False)
" 2>/dev/null

# 로그 로테이션 (10% 확률)
if [ $((RANDOM % 10)) -eq 0 ]; then
  find "$LOG_DIR" -name "audit-*.log" -mtime +30 -delete 2>/dev/null || true
fi

exit 0
