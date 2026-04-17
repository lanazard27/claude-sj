# claude-sj

> Claude Code 멀티 에이전트 오케스트레이션 시스템

**sj**는 Claude Code의 커스텀 에이전트 하네스다. 능글맞은 조수 에이전트가 6명의 전문 에이전트를 지휘하여, 탐색→설계→구현→리뷰→통합까지 자동으로 진행한다.

## 아키텍처

```
사용자
  ↓
sj (오케스트레이터)
  ├── code-explorer  — 코드베이스 탐색
  ├── code-architect — 아키텍처 설계
  ├── code-writer    — 코드 구현/수정
  ├── test-architect — 테스트 케이스 설계
  ├── dev-reviewer   — 코드 리뷰/검증
  └── code-integrator — 병렬 결과물 통합
```

### 에이전트 역할

| 에이전트 | 역할 | 권한 | 모델 |
|---------|------|------|------|
| **sj** | 조율자. 사용자 요청 분석 후 적절한 에이전트에 위임 | 전체 (코드 작성 제외) | opus |
| **code-explorer** | 코드 흐름 추적, 유사 기능 탐색, 아키텍처 매핑 | 읽기 전용 | opus |
| **code-architect** | 기존 패턴 분석 후 최적 아키텍처 설계, 구현 청사인 작성 | 읽기 전용 | opus |
| **code-writer** | 스펙/청사인 기반 코드 구현, 버그 수정, 마이그레이션 | 읽기 + Bash (`cat >`) | opus |
| **test-architect** | 엣지 케이스 분석, 테스트 케이스 명세 설계 | 읽기 전용 | opus |
| **dev-reviewer** | 버그/보안/품질 리뷰. 신뢰도 80점 이상 이슈만 리포트 | 읽기 전용 | opus |
| **code-integrator** | 병렬 작업 결과물 병합, 충돌 해결, 빌드 검증 | 읽기 + Bash | opus |

## 빠른 시작

### 요구사항
- Claude Code CLI
- Git

### 설치

```bash
# 1. 저장소 클론
git clone https://github.com/lanazard27/claude-sj.git

# 2. 프로젝트에 복사
cp -r claude-sj/.claude/ /your-project/.claude/

# 3. 훅 실행 권한 부여
chmod +x /your-project/.claude/hooks/*.sh
chmod +x /your-project/.claude/hooks/lib/*.sh
chmod +x /your-project/.claude/scripts/*.sh
```

또는 설치 스크립트 사용:

```bash
# 대화형 설치 (프로젝트 경로 입력)
bash claude-sj/.claude/scripts/project-init.sh
```

### 첫 대화

```
> 쇼핑몰 장바구니 기능 만들어줘

sj 오, 장바구니? 개발 모드로 들어간다.
먼저 기존 코드베이스에서 비슷한 패턴 찾아볼게...

[code-explorer 탐색 → code-architect 설계 → code-writer 구현 → dev-reviewer 리뷰]
```

## 훅 시스템 (보안 방어선)

모든 도구 실행 전후로 자동 검증이 동작한다.

### PreToolUse 훅

| 훅 | 대상 | 역할 |
|---|------|------|
| `pre-bash-check.sh` | Bash | 위험 명령어 차단 (rm -rf, git push --force 등) |
| `pre-file-check.sh` | Write, Edit | .env, credentials 등 민감 파일 쓰기 차단 |
| `pre-read-check.sh` | Read | 민감 파일 읽기 차단 |
| `pre-security-check.py` | Write, Edit | XSS, SQL Injection, 하드코딩 시크릿 등 보안 패턴 검출 |
| `pre-modify-snapshot.sh` | Write, Edit | 수정 전 파일 백업 |

### PostToolUse 훅

| 훅 | 역할 |
|---|------|
| `audit-log.sh` | 모든 도구 사용 이력 기록 |
| `stats-tracker.sh` | 세션별 통계 수집 |

### Lifecycle 훅

| 훅 | 역할 |
|---|------|
| `session-start.sh` | 세션 시작 시 컨텍스트 복원, Git 상태 출력 |
| `on-stop.sh` | 작업 중단 시 상태 저장 |
| `on-session-end.sh` | 세션 종료 시 메모리 최적화 |
| `on-pre-compact.sh` | 컴팩트 전 작업 상태 백업 |
| `on-subagent-stop.sh` | 하위 에이전트 종료 시 로그 기록 |

### 차단 목록

민감 파일은 `hooks/lib/sensitive-files.sh`에서 통합 관리:

```
.env, .env.*, credentials, secrets, *.pem, *.key, id_rsa, etc.
```

## 워크플로우

### 모드 자동 감지

사용자 요청을 분석해서 최적의 모드로 전환:

| 모드 | 감지 조건 |
|------|----------|
| 🔧 개발 | 코딩, 웹/앱, DB, 인프라 |
| 📚 연구/분석 | 수학, 과학, 일반 지식 |
| ✏️ 창작 | 글쓰기, 번역, 기획 |
| 🎬 미디어 | 영상, 이미지 분석 |
| 🔍 문제해결 | 디버깅, 트러블슈팅 |

### 개발 모드 흐름

```
정보 수집 (10단계) → 사용자 승인 → 구현 → 검증
```

**구현 방식:**
- **일반 (1인)** — code-writer 1명이 순차 구현
- **버스트 (팀)** — code-writer 여럿이 병렬 구현 → code-integrator 통합

**검증 (3-Phase 피드백 루프):**

| Phase | 내용 | 최대 |
|-------|------|------|
| 1. 정적 분석 | dev-reviewer 리뷰 → 수정 → 재리뷰 | 3회 |
| 2. 빌드 | 빌드 실패 → 수정 → 재빌드 | 3회 |
| 3. 테스트 | 테스트 실패 → 수정 → 재테스트 | 3회 |
| **전체** | | **5회** |

### 복잡도 기반 스마트 라우팅

| 복잡도 | 판단 기준 | 에이전트 조합 |
|--------|----------|--------------|
| 단순 | 1-2파일, 기존 패턴 있음 | code-writer만 |
| 중간 | 3-5파일, 신규 기능 | explorer → architect → writer → reviewer |
| 복잡 | 5파일+, 다중 시스템 연동 | explorer → architect → writer(다수) → test-architect → reviewer → integrator |
| 보안 | 인증/권한/결제 관련 | explorer → architect → writer → reviewer(2회) |

## 커스터마이징

### 디렉토리 구조

```
.claude/
├── CLAUDE.md              # 전역 규칙 (Source of Truth)
├── settings.json          # 권한, 훅, deny/allow 설정
├── agents/                # 에이전트 정의
│   ├── sj.md              # 오케스트레이터
│   ├── code-writer.md     # 구현 전담
│   ├── code-explorer.md   # 탐색 전담
│   ├── code-architect.md  # 설계 전담
│   ├── test-architect.md  # 테스트 설계
│   ├── dev-reviewer.md    # 리뷰 전담
│   └── code-integrator.md # 통합 전담
├── hooks/                 # 자동화 훅
│   ├── lib/
│   │   └── sensitive-files.sh  # 민감 파일 목록 (공통)
│   ├── pre-bash-check.sh
│   ├── pre-file-check.sh
│   ├── pre-read-check.sh
│   ├── pre-security-check.py
│   ├── pre-modify-snapshot.sh
│   ├── audit-log.sh
│   ├── stats-tracker.sh
│   ├── session-start.sh
│   ├── on-stop.sh
│   ├── on-session-end.sh
│   ├── on-pre-compact.sh
│   └── on-subagent-stop.sh
├── rules/                 # 상세 규칙
│   ├── modes.md           # 모드 감지 + 개발 워크플로우
│   ├── subagent-rules.md  # 에이전트 위임 규칙
│   ├── maintenance.md     # 메모리 관리 + 유지보수
│   └── context-template.md # 프로젝트 컨텍스트 템플릿
└── scripts/               # 유틸리티 스크립트
    ├── project-init.sh    # 프로젝트 초기화
    └── memory-optimize.sh # 메모리 최적화
```

### 에이전트 수정

`agents/` 디렉토리의 `.md` 파일을 편집하면 에이전트 동작을 커스터마이징할 수 있다. YAML frontmatter의 `tools` 필드로 도구 권한을 제어한다.

### 훅 수정

- **차단 파일 추가**: `hooks/lib/sensitive-files.sh`에 경로 추가
- **위험 명령어 추가**: `settings.json`의 `permissions.deny`에 패턴 추가
- **보안 패턴 추가**: `hooks/pre-security-check.py`에 패턴 추가

### 규칙 수정

- **CLAUDE.md**: 전역 규칙 (모든 에이전트가 참조)
- **rules/*.md**: 상세 규칙 (CLAUDE.md에서 `@rules/`로 import)

## 라이선스

MIT
