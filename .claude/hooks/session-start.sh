#!/bin/bash
# ~/.claude/hooks/session-start.sh
# SessionStart hook — 세션 시작 시 개발 컨텍스트 자동 로드
# stdout이 Claude의 컨텍스트에 추가됨

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# 경로 검증: 인쇄 불가 문자와 경로 탈출 패턴 차단
if [[ "$PROJECT_DIR" =~ [^[:print:]] ]] || [[ "$PROJECT_DIR" == *".."* ]]; then
  echo "(잘못된 프로젝트 경로가 감지되었습니다)"
  exit 1
fi

# 경로 정규화
PROJECT_DIR=$(realpath "$PROJECT_DIR" 2>/dev/null || echo "$PROJECT_DIR")

# 동적 메모리 경로: 프로젝트 디렉토리 기반으로 자동 계산
# 경로의 /를 -로 변환하여 .claude/projects/-{encoded-path}/memory 형식 생성
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"

echo "=== 세션 시작 컨텍스트 ==="
echo "프로젝트: $PROJECT_DIR"
echo "시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ============================================================
# Git 상태 (프로젝트가 git repo인 경우)
# ============================================================
if [ -d "$PROJECT_DIR/.git" ]; then
  echo "--- 최근 커밋 ---"
  cd "$PROJECT_DIR" && git log --oneline -5 2>/dev/null || echo "(git log 실패)"
  echo ""
  echo "--- 작업 트리 상태 ---"
  cd "$PROJECT_DIR" && git status --short 2>/dev/null | head -20 || echo "(git status 실패)"
  echo ""
  echo "--- 현재 브랜치 ---"
  cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "(브랜치 확인 실패)"
  echo ""
else
  echo "(git 저장소가 아닌 디렉토리입니다)"
  echo ""
fi

# ============================================================
# 멀티 프로젝트 전환 감지
# ============================================================
LAST_PROJECT_FILE="$HOME/.claude/last-project"
if [ -f "$LAST_PROJECT_FILE" ]; then
  LAST_PROJECT=$(cat "$LAST_PROJECT_FILE" 2>/dev/null || echo "")
  if [ -n "$LAST_PROJECT" ] && [ "$LAST_PROJECT" != "$PROJECT_DIR" ]; then
    echo "--- 프로젝트 전환 감지 ---"
    echo "이전: $LAST_PROJECT"
    echo "현재: $PROJECT_DIR"
    echo "주의: 이전 프로젝트의 컨텍스트를 현재 프로젝트에 적용하지 마세요."
    echo ""
  fi
fi

# 현재 프로젝트 기록
echo "$PROJECT_DIR" > "$LAST_PROJECT_FILE"

# ============================================================
# 프로젝트 CONTEXT.md 자동 감지
# ============================================================
CONTEXT_FILE="$PROJECT_DIR/CONTEXT.md"
if [ -f "$CONTEXT_FILE" ]; then
  echo "--- 프로젝트 컨텍스트 (CONTEXT.md) ---"
  head -30 "$CONTEXT_FILE" 2>/dev/null || true
  echo ""
fi

# ============================================================
# 세션 통계 표시 (있는 경우)
# ============================================================
STATS_FILE="$MEMORY_DIR/../stats/usage.json"
if [ -f "$STATS_FILE" ]; then
  TODAY=$(date '+%Y-%m-%d')
  TODAY_STATS=$(python3 -c "
import json, sys
try:
    stats = json.load(open('$STATS_FILE'))
    today = stats.get('$TODAY', {})
    tools = today.get('tools', {})
    agents = today.get('agents', {})
    files = today.get('files_modified', 0)
    sessions = len(today.get('sessions', []))
    print(f'도구: {sum(tools.values())}회 | 파일수정: {files}개 | 세션: {sessions}개')
except:
    pass
" 2>/dev/null || echo "")
  if [ -n "$TODAY_STATS" ]; then
    echo "--- 오늘 통계 ---"
    echo "$TODAY_STATS"
    echo ""
  fi
fi

# ============================================================
# 관련 memory 자동 요약 (기술 스택 매칭)
# ============================================================
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
  MEMORY_SNIPPET=$(grep -i -E "(기술|스택|프레임워크|DB|프로젝트|선호|컨벤션|패턴|주의|금지)" "$MEMORY_FILE" 2>/dev/null | head -10 || true)
  if [ -n "$MEMORY_SNIPPET" ]; then
    echo "--- 이전 경험 요약 ---"
    echo "$MEMORY_SNIPPET"
    echo ""
  fi
fi

# ============================================================
# 메모리 건강 체크
# ============================================================
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"

# MEMORY.md 크기 경고
if [ -f "$MEMORY_FILE" ]; then
  MEMORY_LINES=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [ "$MEMORY_LINES" -gt 150 ]; then
    echo "--- 메모리 경고 ---"
    echo "MEMORY.md: ${MEMORY_LINES}/200줄 (곧 자동 압축됩니다)"
    echo ""
  fi
fi

# experience 카테고리 누적 경고
if [ -f "$MEMORY_DIR/.experience-warning" ]; then
  EXP_COUNT=$(cat "$MEMORY_DIR/.experience-warning" 2>/dev/null || echo "0")
  echo "--- experience 누적 ---"
  echo "카테고리 ${EXP_COUNT}개 — 5개 초과. 오래된 카테고리를 인사이트로 압축하세요."
  echo ""
fi

exit 0
