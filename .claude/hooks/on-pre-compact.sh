#!/bin/bash
# ~/.claude/hooks/on-pre-compact.sh
# PreCompact hook — compact 실행 전 중요 컨텍스트를 stdout으로 Claude에게 전달
# v2: WIP + 사용자 선호 + 수정 중인 파일 + TODO/FIXME + 복구 체크리스트

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"
WIP_FILE="$MEMORY_DIR/work-in-progress.md"

INPUT=$(cat 2>/dev/null || echo "")
MATCHER=""

if [ -n "$INPUT" ]; then
  MATCHER=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('matcher',''))" 2>/dev/null || echo "")
fi

echo "=== Compact 전 컨텍스트 보존 ==="
echo "compact 타입: ${MATCHER:-auto}"
echo ""

# ============================================================
# 1. WIP 상태 보존
# ============================================================
if [ -f "$WIP_FILE" ]; then
  WIP_STATUS=$(grep -A 1 "^- \*\*상태\*\*" "$WIP_FILE" 2>/dev/null | head -1 | sed 's/^- \*\*상태\*\*: //' || echo "")
  if [ -n "$WIP_STATUS" ] && [ "$WIP_STATUS" != "없음" ]; then
    echo "--- 진행 중인 작업 ---"
    grep -A 8 "^## 현재 작업" "$WIP_FILE" 2>/dev/null | head -9 || true
    echo ""
  fi
fi

# ============================================================
# 2. 사용자 핵심 선호 보존
# ============================================================
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  echo "--- 사용자 선호 ---"
  head -20 "$MEMORY_DIR/MEMORY.md" 2>/dev/null || true
  echo ""
fi

# ============================================================
# 3. 수정 중인 파일 목록 (스냅샷에서 추출)
# ============================================================
SNAPSHOT_DIR="$MEMORY_DIR/snapshots"
if [ -d "$SNAPSHOT_DIR" ]; then
  LATEST_SESSION=$(ls -t "$SNAPSHOT_DIR" 2>/dev/null | head -1)
  if [ -n "$LATEST_SESSION" ] && [ -d "$SNAPSHOT_DIR/$LATEST_SESSION" ]; then
    SNAPSHOTS=$(ls "$SNAPSHOT_DIR/$LATEST_SESSION" 2>/dev/null)
    if [ -n "$SNAPSHOTS" ]; then
      echo "--- 수정 중인 파일 (스냅샷 기준) ---"
      echo "$SNAPSHOTS" | while read -r f; do
        echo "- $f"
      done
      echo ""
    fi
  fi
fi

# ============================================================
# 4. 열려있는 TODO/FIXME 스캔
# ============================================================
if [ -d "$PROJECT_DIR" ]; then
  TODOS=$(cd "$PROJECT_DIR" && grep -rn "TODO\|FIXME\|HACK\|XXX" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --include="*.py" --include="*.go" --include="*.rs" \
    . 2>/dev/null | head -10 || true)
  if [ -n "$TODOS" ]; then
    echo "--- 열려있는 TODO/FIXME (최대 10개) ---"
    echo "$TODOS"
    echo ""
  fi
fi

# ============================================================
# 5. Compact 후 복구 체크리스트
# ============================================================
echo "--- Compact 후 복구 체크리스트 ---"
echo "1. 위 '진행 중인 작업' 상태 확인"
echo "2. 수정 중인 파일이 있으면 git diff로 변경사항 검증"
echo "3. TODO/FIXME 중 현재 작업과 관련된 것 처리 여부 확인"
echo ""

echo "=== compact를 진행하세요. 위 정보는 compact 후에도 유지됩니다. ==="

exit 0
