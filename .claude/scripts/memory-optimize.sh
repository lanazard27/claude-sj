#!/bin/bash
# memory-optimize.sh — 메모리 자동 최적화 유틸리티
# on-session-end.sh에서 호출됨
#
# 기능:
# 1. MEMORY.md 150줄 초과 시 오래된 항목 압축
# 2. experience.md 동일 카테고리 5개+ 누적 시 일반화 안내

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"
OPTIMIZED=false

# ============================================================
# 1. MEMORY.md 압축 (150줄 초과 시)
# ============================================================
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
  LINE_COUNT=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [ "$LINE_COUNT" -gt 150 ]; then
    # 핵심 섹션(# 제목)만 유지, 빈 줄 정리
    # 마지막 120줄 유지 (200줄 제한에서 여유분 확보)
    TEMP_FILE=$(mktemp)
    head -5 "$MEMORY_FILE" > "$TEMP_FILE"  # 헤더 유지
    tail -115 "$MEMORY_FILE" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$MEMORY_FILE"
    OPTIMIZED=true
  fi
fi

# ============================================================
# 2. experience.md 카테고리 누적 경고 (5개+)
# ============================================================
EXP_FILE="$MEMORY_DIR/experience.md"
if [ -f "$EXP_FILE" ]; then
  CATEGORY_COUNT=$(grep -c "^## 카테고리:" "$EXP_FILE" 2>/dev/null || echo "0")
  if [ "$CATEGORY_COUNT" -gt 5 ]; then
    # 카테고리가 5개 초과면 경고 마커 파일 생성 (session-start에서 표시)
    echo "$CATEGORY_COUNT" > "$MEMORY_DIR/.experience-warning"
    OPTIMIZED=true
  else
    rm -f "$MEMORY_DIR/.experience-warning" 2>/dev/null
  fi
fi

# 결과 출력 (on-session-end에서 로깅용)
if [ "$OPTIMIZED" = true ]; then
  echo "memory-optimized"
fi
