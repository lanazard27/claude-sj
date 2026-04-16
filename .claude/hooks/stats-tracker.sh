#!/bin/bash
# stats-tracker.sh — 도구 사용 통계 누적 (PostToolUse async)
# 감사 로그와 함께 비동기 실행 — 성능 영향 최소화

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
STATS_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/stats"
mkdir -p "$STATS_DIR"

INPUT=$(cat 2>/dev/null || echo "")
[ -z "$INPUT" ] && exit 0

# 환경변수로 경로 전달 (인용부호 이슈 방지)
export STATS_FILE="$STATS_DIR/usage.json"

echo "$INPUT" | python3 -c "
import sys, json, os
from datetime import datetime, timedelta

stats_file = os.environ.get('STATS_FILE', '')
if not stats_file:
    sys.exit(0)

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool = d.get('tool_name', 'unknown')
agent = d.get('agent_name', d.get('agent_type', '')) or 'sj'
session_id = d.get('session_id', '')
ti = d.get('tool_input', {})
subagent = ti.get('subagent_type', '') if tool == 'Agent' else ''

stats = {}
if os.path.exists(stats_file):
    try:
        with open(stats_file) as f:
            stats = json.load(f)
    except Exception:
        pass

today = datetime.now().strftime('%Y-%m-%d')
if today not in stats:
    stats[today] = {'tools': {}, 'agents': {}, 'subagents': {}, 'files_modified': 0, 'sessions': []}

# 세션 추적
if session_id and session_id not in stats[today]['sessions']:
    stats[today]['sessions'].append(session_id)

# 도구별 카운트
stats[today]['tools'][tool] = stats[today]['tools'].get(tool, 0) + 1

# 에이전트별 카운트
stats[today]['agents'][agent] = stats[today]['agents'].get(agent, 0) + 1

# 서브에이전트별 카운트
if subagent:
    stats[today]['subagents'][subagent] = stats[today]['subagents'].get(subagent, 0) + 1

# 파일 수정 카운트
if tool in ('Write', 'Edit'):
    stats[today]['files_modified'] = stats[today].get('files_modified', 0) + 1

# 30일 이전 데이터 정리
cutoff = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
for k in list(stats.keys()):
    if k < cutoff:
        del stats[k]

with open(stats_file, 'w') as f:
    json.dump(stats, f, indent=2, ensure_ascii=False)
" 2>/dev/null

exit 0
