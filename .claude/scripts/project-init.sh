#!/bin/bash
# project-init.sh — 새 프로젝트 초기화 스크립트
# 사용법: bash .claude/scripts/project-init.sh [프로젝트경로]
# 기능: 프로젝트 유형 감지 → CLAUDE.md 생성 → 메모리 초기화

PROJECT_DIR="${1:-$(pwd)}"

echo "=== 프로젝트 초기화 ==="
echo "경로: $PROJECT_DIR"
echo ""

# ============================================================
# 1. 프로젝트 유형 감지
# ============================================================
detect_project_type() {
  if [ -f "$PROJECT_DIR/package.json" ]; then
    if grep -q '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
      echo "nextjs"
    elif grep -q '"react"' "$PROJECT_DIR/package.json" 2>/dev/null; then
      echo "react"
    elif grep -q '"vue"' "$PROJECT_DIR/package.json" 2>/dev/null; then
      echo "vue"
    else
      echo "node"
    fi
  elif [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
    if [ -f "$PROJECT_DIR/manage.py" ]; then
      echo "django"
    elif grep -q "fastapi" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
      echo "fastapi"
    else
      echo "python"
    fi
  elif [ -f "$PROJECT_DIR/go.mod" ]; then
    echo "go"
  elif [ -f "$PROJECT_DIR/Cargo.toml" ]; then
    echo "rust"
  else
    echo "generic"
  fi
}

PROJECT_TYPE=$(detect_project_type)
echo "감지된 프로젝트 유형: $PROJECT_TYPE"
echo ""

# ============================================================
# 2. .claude 디렉토리 생성
# ============================================================
mkdir -p "$PROJECT_DIR/.claude"
echo "✓ .claude/ 디렉토리 준비"

# ============================================================
# 3. CLAUDE.md 생성 (유형별 커스텀)
# ============================================================
if [ ! -f "$PROJECT_DIR/.claude/CLAUDE.md" ]; then
  cat > "$PROJECT_DIR/.claude/CLAUDE.md" << 'HEADER'
# 프로젝트 규칙

## 기본 원칙
- 한국어로 응답할 것
- CLAUDE.md가 Source of Truth

## 기술 스택
HEADER

  case "$PROJECT_TYPE" in
    nextjs)
      cat >> "$PROJECT_DIR/.claude/CLAUDE.md" << 'EOF'
- **Next.js** (App Router)
- Server Component 기본, 'use client' 최소화
- Next.js Image 컴포넌트 사용 (`<img>` 금지)
EOF
      ;;
    react)
      cat >> "$PROJECT_DIR/.claude/CLAUDE.md" << 'EOF'
- **React** (Vite / CRA)
- 함수형 컴포넌트 + Hooks
- 상태 관리: 프로젝트 기존 방식 따름
EOF
      ;;
    django)
      cat >> "$PROJECT_DIR/.claude/CLAUDE.md" << 'EOF'
- **Django** (Python)
- Django ORM 사용, raw SQL 금지
- settings.py 환경 분리
EOF
      ;;
    fastapi)
      cat >> "$PROJECT_DIR/.claude/CLAUDE.md" << 'EOF'
- **FastAPI** (Python)
- Pydantic 모델로 입력 검증
- 비동기 처리 우선
EOF
      ;;
    go)
      cat >> "$PROJECT_DIR/.claude/CLAUDE.md" << 'EOF'
- **Go**
- 표준 라이브러리 우선
- 에러 처리: explicit error checking
EOF
      ;;
    *)
      cat >> "$PROJECT_DIR/.claude/CLAUDE.md" << 'EOF'
- 일반 프로젝트 (유형 자동 감지 실패)
EOF
      ;;
  esac
  echo "✓ CLAUDE.md 생성 (유형: $PROJECT_TYPE)"
else
  echo "- CLAUDE.md 이미 존재 (스킵)"
fi

# ============================================================
# 4. 메모리 디렉토리 초기화
# ============================================================
ENCODED_DIR=$(echo "$PROJECT_DIR" | sed 's|^/||;s|/$||;s|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/-${ENCODED_DIR}/memory"
mkdir -p "$MEMORY_DIR"

if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
  cat > "$MEMORY_DIR/MEMORY.md" << 'EOF'
# 사용자 선호

# 핵심 교훈
EOF
  echo "✓ MEMORY.md 생성"
else
  echo "- MEMORY.md 이미 존재 (스킵)"
fi

if [ ! -f "$MEMORY_DIR/work-in-progress.md" ]; then
  cat > "$MEMORY_DIR/work-in-progress.md" << 'EOF'
# 작업 진행 상태 (Work In Progress)

## 현재 작업

- **상태**: 없음

## 최근 완료 (최근 5개)

| 날짜 | 프로젝트 | 작업 요약 | 마지막 커밋 |
|------|----------|-----------|-------------|
EOF
  echo "✓ WIP 파일 생성"
else
  echo "- WIP 파일 이미 존재 (스킵)"
fi

# ============================================================
# 5. 완료
# ============================================================
echo ""
echo "=== 초기화 완료 ==="
echo "프로젝트 유형: $PROJECT_TYPE"
echo "메모리 경로: $MEMORY_DIR"
echo ""
echo "다음 단계:"
echo "1. $PROJECT_DIR/.claude/CLAUDE.md 를 프로젝트에 맞게 수정"
echo "2. sj1 하네스의 .claude/ (rules/, agents/, hooks/, settings.json) 를 복사"
echo "3. Claude Code 실행"

exit 0
