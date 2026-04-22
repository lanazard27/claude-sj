# Sub-agent 위임 규칙

## Token Budget (토큰 예산)

에이전트 스폰 시 출력 토큰 소비를 관리하여 세션 컨텍스트를 보호.

| 에이전트 | 권장 max_turns | 이유 |
|---------|---------------|------|
| code-explorer | 15 | 탐색은 빠르게, 필요시 재스폰 |
| code-architect | 20 | 설계는 신중하게, 하지만 불필요한 반복 금지 |
| code-writer (단순) | 15 | sonnet 권장 (haiku는 파일 생성 누락 잦음), 1-2파일 |
| code-writer (중간) | 20 | 3-5파일, 셀프 리뷰 포함 |
| code-writer (복잡) | 30 | 5파일+, 설계 판단 필요 |
| spec-reviewer | 10 | 리뷰만, 수정은 writer가 |
| quality-reviewer | 10 | 리뷰만 |
| test-architect | 15 | 설계만, 구현은 writer가 |
| code-integrator | 20 | 병합 + 빌드 검증 |

**sj 체크**: 에이전트 완료 후 응답 길이가 과도하게 길면 (5K+ 토큰) 다음 스폰에서 프롬프트를 더 구체화하여 범위 축소.

## Routing (요청 분류)

| 요청 유형 | 에이전트 | 모델 | 복잡도 | 워크플로우 |
|----------|---------|------|--------|----------|
| 코드베이스 탐색 | `code-explorer` | sonnet | 중간 | 유사 기능 찾기, 구조 파악 |
| 아키텍처 설계 | `code-architect` | opus | 복잡 | 청사인, 설계 결정 |
| 코드 구현 (단순) | `code-writer` | sonnet | 단순 | 1-2파일, 기존 패턴. **haiku는 파일 생성 누락 위험** |
| 코드 구현 (중간) | `code-writer` | sonnet | 중간 | 3-5파일, 약간 판단 |
| 코드 구현 (복잡) | `code-writer` | opus | 복잡 | 5파일+, 설계 판단 |
| 테스트 케이스 설계 | `test-architect` | sonnet | 중간 | 엣지 케이스, 테스트 명세 |
| 스펙 준수 리뷰 | `spec-reviewer` | opus | 복잡 | PRD와 구현 일치 |
| 코드 품질 리뷰 | `quality-reviewer` | opus | 복잡 | 보안, 성능, 패턴 |
| 결과물 병합 | `code-integrator` | sonnet | 중간 | 병렬 작업 통합, 충돌 해결 |

**복잡도 워크플로우:** 단순→writer만. 중간→PRD→architect→writer→reviewer. 복잡→PRD→architect(스펙분할)→Phase0→writers병렬(3-6파일씩)→writer(연결)→reviewer. 보안→reviewer(2회). 테스트→test-architect→writer→reviewer

## 모델 승격 (작업 복잡도 기반)

**기본 원칙**: 가장 약한 모델로 시작, 필요시 승격

| 복잡도 | 판단 신호 | 모델 | 예시 |
|--------|----------|------|------|
| **단순** | 1-2파일, 명확한 스펙, 기존 패턴 | sonnet | 버튼 추가, API 1개, 상수 (haiku 파일 생성 누락 위험) |
| **중간** | 3-5파일, 약간의 판단, 새 기능 | sonnet | 컴포넌트, 미들웨어, 훅 |
| **복잡** | 5파일+, 설계 판단, 다중 연동 | opus | 아키텍처, 상태관리, 보안 |

**에이전트별 기본 모델**: code-explorer(sonnet→opus), code-architect(opus), code-writer(복잡도에 따라), test-architect(sonnet→opus), spec-reviewer(opus), quality-reviewer(opus), code-integrator(sonnet→opus)

## 위임 패턴

### 1. Prompt Chaining (순차)
```
code-architect → code-writer(셀프 리뷰) → spec-reviewer → quality-reviewer
```

### 2. Pipeline Parallelization (병렬 파이프라인) ⭐

**스펙 단위 분할 기본:** 레이어별이 아니라 기능/스펙 단위로 분할. 각 code-writer가 완결된 기능 전체 담당.

```
Phase 0: 공통 기반 (1명) → types, constants, hooks, utils, 설정, 인터페이스 계약서
Phase 1: 스펙별 병렬 (N명) → 각 스펙 A/B/N 전체 (상수+엔진+렌더러+UI)
Phase 2: 연결 (1명) → reducer, App.jsx, 라우팅, 연결
Phase 3: 검증 → spec-reviewer → quality-reviewer
```

**분할 규칙:** 각 스펙은 완결된 기능, 여러 레이어 파일 담당, 스펙 간 파일 겹침 금지, 공통 파일은 Phase 0, 연결 파일은 Phase 2

**분할 기준:** 사용자 스토리 단위로 자연스럽게 나뉨, 스펙 간 충돌 없음, 각 스펙 3-6개 파일, 의존성 최소

**분할 사전 검증 (sj 실행):** 파일 중복 없음? 숨은 의존성 없음? 각 스펙 3-6개 파일? Phase 2 연결 복잡도 10개+면 순차 전환

#### 에이전트당 파일 수 제한 (퀄리티 핵심)

| 파일 수 | 퀄리티 | 권장 |
|---------|--------|------|
| 1-3개 | 최상 | ✅ |
| 4-6개 | 양호 | 가능 |
| 7-10개 | 저하 | ⚠️ 분할 권장 |
| 10개+ | 낮음 | ❌ 반드시 분할 |

- **code-writer 1명당 3-6개 파일 적정** — 이상 퀄리티 급격히 떨어짐
- 7개+ 파일이면 2명으로 분할, 각 에이전트 프롬프트에 수정 가능/금지 파일 목록 명시

### 3. Routing (분류)
단일 에이전트로 처리. 간단한 작업.

### 4. Evaluator-Optimizer (2단계 리뷰)

**원칙: 스펙 준수 PASS 후 코드 품질 리뷰. 순서 절대 바꾸지 않음.**

- **Step 0: 셀프 리뷰** — Read로 재확인, 누락/하드코딩/미사용 import 체크, 이슈 시 직접 수정
- **Step 1: 스펙 준수 리뷰** — PRD 요구사항 모두 구현, 스펙에 없는 기능 추가 없음, 에러 시나리오 처리, PASS/FAIL
- **Step 2: 코드 품질 리뷰** — Step 1 PASS 후만 실행, 보안/성능/패턴 준수, APPROVED/ISSUES

**최대 반복**: 각 단계 2회, 전체 4회. 4회 도달 시 사용자 보고.

## 에이전트 상태 관리 (Superpowers)

모든 에이전트는 작업 완료 후 반드시 아래 **상태 중 하나** 반환:

| 상태 | 의미 | sj 대응 |
|------|------|---------|
| **DONE** | 작업 완료, 이슈 없음 | 다음 단계 진행 |
| **DONE_WITH_CONCERNS** | 완료했지만 우려사항 있음 | 검토 후 진행. 문제면 수정 |
| **NEEDS_CONTEXT** | 정보 부족으로 작업 불가 | sj가 정보 제공 후 새 스폰 |
| **BLOCKED** | 근본적 차단 | 컨텍스트 보충/모델 승격/태스크 분할/에스컬레이션 |

**BLOCKED 처리 우선순위:** 1)컨텍스트 문제→정보 제공 후 새 스폰 2)능력 부족→상위 모델로 승격 후 새 스폰 3)태스크 과대→작게 분할 후 재스폰 4)설계 자체 오류→사용자 에스컬레이션

**절대 하지 않을 것:** 같은 모델/프롬프트로 재시도, BLOCKED 무시하고 강제 진행

### DONE_WITH_CONCERNS 자동 분류

| 카테고리 | 판단 기준 | sj 대응 |
|---------|----------|---------|
| **진행 가능** | "파일이 길어짐", "리팩토링하면 좋겠음" | 기록 후 진행 |
| **검토 필요** | "패턴이 다름", "확신 없음" | sj가 Read로 확인 후 진행 |
| **수정 필요** | "요구사항 일부만 구현", "에러 누락" | FAIL과 동일. 수정 지시 |

**분류 원칙:** 애매하면 한 단계 아래로, 사용자에게 간단히 보고

### 5. Orchestrator-Workers (버스트)
```
sj 분석 → code-writer 여럿 스폰 → code-integrator 병합
```
상세: `.claude/memory/team-burst-template.md`

## Agent vs Teammate

| 상황 | 선택 |
|------|------|
| 독립 작업, 단발성 | **Agent** |
| 병렬 구현 | **Agent** (+ isolation="worktree") |
| 작업 중간 협업 필요 | **Teammate** |

## #2 새 의존성 사전 설치 (sj 책임)
architect 완료 후 Phase F(구현) 전에: 1)architect 출력에서 "새 의존성" 섹션 확인 2)새 패키지 있으면 sj가 직접 설치: `cd [프로젝트경로] && npm install [패키지@버전]` 3)설치 실패 시 버전 조정 후 재시도(최대 2회) 4)writer는 이미 설치된 것으로 간주하고 import만 작성

## #4 DB 스키마 변경 (Phase 0 포함)
1)architect가 구현 맵에 schema.prisma 수정 포함(또는 migration 파일) 2)Phase 0에서 스키마 수정 + migration 실행: schema.prisma 수정 → `npx prisma migrate dev --name [기능명]` → `npx prisma generate` 3)Phase 1 writers는 수정된 스키마 기반으로 구현 4)마이그레이션 실패 시 sj가 롤백 후 원인 파악

## 위임 프롬프트 필수 항목
1. **역할**: 명확한 역할 정의
2. **범위**: 접근할 파일/디렉토리 명시 (범위 밖 금지)
3. **제약**: 한국어, 범위 밖 수정 금지, 정보 부족 시 질문 가능 (기술 스택/아키텍처 결정 제외)
4. **출력**: 반환 형식 + **상태 반환 필수** (DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED)
5. **컨텍스트**: 부모 세션에서 학습한 중요 맥락 포함
6. **결정사항**: sj가 미리 결정한 기술적 선택 포함 (버전, DB, 환경변수)
7. **실행 강조**: "반드시 실제 도구로 파일 생성. **파일 생성/수정 시 Edit/Write 대신 Bash `cat >` 사용** (권한 팝업 방지). 보고서만 작성 금지."
8. **스키마 참조**: Prisma/DB 스키마 작업 시 관련 모델 정의 포함 (필드명 불일치 방지)
9. **자가 검증**: 파일 생성 후 기본 문법 체크 지시 (같은 키 중복, 괄호 질 불일치 등)
10. **CONTEXT.md 활용**: 프로젝트에 `CONTEXT.md` 있으면 "작업 전 CONTEXT.md를 읽고 기술 스택/스키마/컨벤션 파악" 추가

### 위임 프롬프트 템플릿 (필수 사용)
에이전트 스폰 시 **반드시** `rules/delegation-templates.md`의 해당 템플릿 사용. 템플릿 없이 자유 형식 위임 금지.

**Verbatim 복사 원칙 (가장 중요):** architect/explorer/test-architect의 출력을 sj가 재작성/요약하지 않음. 마크다운 블록을 통째로 `---` 사이에 복사. 이전 에이전트가 지정한 함수명, 파일 경로, 인터페이스가 누락되면 writer가 정확히 구현 불가. **"sj의 이해"로 필터링하지 말고 원문 그대로 전달**

## 에이전트 질문 처리 (제한적 허용)

**원칙: 에이전트가 막히면 질문하게 두는 것이, 잘못된 작업을 하는 것보다 낫다.**

- 작업 시작 전 질문 → sj가 즉시 답변 → 같은 에이전트 계속 진행
- 작업 중 막힘 → NEEDS_CONTEXT 상태 반환 → sj가 정보 제공 후 새 스폰

**질문 허용 범위:** 허용 — 파일 경로, 스키마 필드명, 기존 패턴 위치, API 엔드포인트 형식. 허용 안 함 — 기술 스택 선택, 아키텍처 결정, 라이브러리 버전(sj가 이미 결정)

**sj의 대응:** 1)에이전트 질문을 읽고 sj가 직접 답변(사용자에게 전달하지 않음) 2)답변 근거: 이전 경험, memory, 프로젝트 컨텍스트, 안정성 우선 3)답변을 포함해 새 에이전트 스폰(resume 금지) 4)사용자에게는 "에이전트가 X에 대해 질문해서 Y라고 답변했어" 정도로 요약

**resume 사용 금지:** 질문 처리 시에도 resume 대신 새 스폰

## resume 사용 규칙
- **같은 세션(compact 전)에서만 사용** — compact 이전에 스폰한 에이전트만 resume 가능
- **compact 후 이전 에이전트 ID 사용 금지** — 컨텍스트 초기화로 ID-작업 매핑 상실

## 에이전트 권한

| 에이전트 | 권한 | 비고 |
|---------|------|------|
| `code-explorer` | Read, Glob, Grep | 읽기 전용 |
| `code-architect` | Read, Glob, Grep | 읽기 전용 |
| `code-writer` | Read, Glob, Grep, Bash | **구현 전담 (Bash `cat >` 사용)** |
| `test-architect` | Read, Glob, Grep | 읽기 전용 (설계만) |
| `spec-reviewer` | Read, Glob, Grep | 스펙 준수 리뷰 전담 |
| `quality-reviewer` | Read, Glob, Grep | 코드 품질 리뷰 전담 |
| `code-integrator` | Read, Glob, Grep, Bash | 통합/git 전담 |
| `sj` | 전체 | **조율만, 코드 작성 금지** |

## 전문 도메인 에이전트 (선택적 활용)

`~/.claude/agents/`에 설치된 도메인 전문 에이전트를 sj의 기본 에이전트로 커버 안 되는 영역에 선택적으로 활용.

**활용 매핑:** 보안(@security-engineer) / DevOps(@devops-architect) / 성능(@performance-engineer) / 비즈니스(@business-panel-experts) / 근원 원인(@root-cause-analyst) / 요구사항(@requirements-analyst) / 기술 문서(@technical-writer) / 학습(@learning-guide, @socratic-mentor) / 저장소(@repo-index) / 리팩토링(@refactoring-expert) / Python(@python-expert)

**사용 원칙:** 보조 도구(sj 기본 에이전트가 주축), 필요시에만 선택적 호출, sj가 조율, 상태 반환 동일(DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED)

## 역할 분리 원칙
- **작성 vs 리뷰 분리**: 같은 에이전트가 작성+리뷰하지 않음
- **스펙 리뷰 vs 품질 리뷰 분리**: spec-reviewer와 quality-reviewer는 독립
- **설계 vs 구현 분리**: architect 설계 → writer 구현
- **범위 충돌 방지**: 다른 에이전트가 같은 파일 동시 수정 금지

## 에이전트 결과물 품질 체크리스트
에이전트 작업 완료 후 sj가 확인: 1)파일 실제 생성 확인(보고서만 쓰고 파일 안 만들었으면 재실행) 2)Prisma 필드명 일치(스키마에 없는 필드 사용했는지) 3)문법 에러(빌드 실행으로 검증) 4)범위 준수(지시하지 않은 파일 수정했는지)

## 자동 검증 루프 (파일 생성 강제)
code-writer 완료 후 **반드시** 아래 절차 자동 실행:

- **Step 1: 예상 파일 존재 확인** — `ls -la <프로젝트경로>/<예상파일들>`
- **Step 2: 판정** — 전부 존재+비어있지 않음→통과, 일부/전부 누락→재스폰(시도 1)
- **Step 3: 재시도(최대 2회)** — 2회 연속 실패→사용자 보고, 성공→통과

**재스폰 프롬프트:** "이전 시도에서 파일을 생성하지 않고 텍스트만 반환했습니다. **반드시 Bash cat > 로 실제 파일을 생성하세요.**", 이전 텍스트 내용, 누락 파일 목록

**주의:** resume 금지, 사용자에게 묻지 않음, 2회 초과 시 중단

## architect 출력 품질 자동 검증
architect 완료 후 **반드시** 아래 항목 확인:

- **Step 1: 필수 섹션 확인** — 인터페이스 계약서, 핵심 로직 의사코드, 에러 시나리오 테이블, 기존 코드 참조, 구현 제약사항, 구현 맵
- **Step 2: 기존 코드 참조 실제 존재 확인** — `ls -la [참조한 파일 경로]`
- **Step 3: 판정** — 필수 섹션 누락→재스폰(최대 1회), 전부 충족→통과, writer에게 전달

## 하위 호환성
- `isolation="worktree"`: 일반 스폰에서만 작동, 팀 스폰에서는 수동 worktree 생성 필요
