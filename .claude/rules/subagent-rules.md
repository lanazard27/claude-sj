# Sub-agent 위임 규칙

## Routing (요청 분류)

| 요청 유형 | 에이전트 | 모델 | 언제 |
|----------|---------|------|------|
| 코드베이스 탐색 | `code-explorer` | sonnet | 유사 기능 찾기, 구조 파악 |
| 아키텍처 설계 | `code-architect` | opus | 청사인, 설계 결정 |
| 코드 구현/수정 (단순) | `code-writer` | haiku | 1-2파일, 기존 패턴 있음 |
| 코드 구현/수정 (중간) | `code-writer` | sonnet | 3-5파일, 약간의 판단 필요 |
| 코드 구현/수정 (복잡) | `code-writer` | opus | 5파일+, 설계 판단 필요 |
| 테스트 케이스 설계 | `test-architect` | sonnet | 엣지 케이스, 테스트 명세 |
| 스펙 준수 리뷰 | `spec-reviewer` | opus | PRD와 구현 일치 여부 |
| 코드 품질 리뷰 | `quality-reviewer` | opus | 보안, 성능, 패턴 준수 |
| 결과물 병합 | `code-integrator` | sonnet | 병렬 작업 통합, 충돌 해결 |

## 복잡도 기반 스마트 라우팅

작업 복잡도에 따라 자동으로 에이전트 조합 결정:

| 복잡도 | 판단 기준 | 워크플로우 |
|--------|----------|------------|
| 단순 | 1-2파일, 기존 패턴 있음 | code-writer만 |
| 중간 | 3-5파일, 신규 기능 | PRD → architect → writer → reviewer |
| 복잡 | 5파일+, 다중 기능 | PRD → architect(스펙 분할) → Phase 0(공통) → **writers 스펙별 병렬(3-6파일씩)** → writer(연결) → reviewer |
| 보안 | 인증/권한/결제 관련 | PRD → architect → writer → reviewer(2회) |
| 테스트 | 테스트 커버리지 강화 | test-architect(설계) → writer(구현) → reviewer(검증) |

## 모델 승격 — 작업 복잡도 기반 (Superpowers 방식)

### 기본 원칙: 가장 약한 모델로 시작, 필요시 승격

| 복잡도 | 판단 신호 | 모델 | 예시 |
|--------|----------|------|------|
| **단순** | 1-2파일, 명확한 스펙, 기존 패턴 있음 | haiku | 버튼 추가, API 엔드포인트 1개, 상수 정의 |
| **중간** | 3-5파일, 약간의 판단 필요, 새 기능 | sonnet | 새 컴포넌트, 미들웨어 추가, 훅 작성 |
| **복잡** | 5파일+, 설계 판단, 다중 시스템 연동 | opus | 아키텍처 설계, 복잡한 상태관리, 보안 로직 |

### 에이전트별 기본 모델

| 에이전트 | 기본 | 승격 조건 | 비고 |
|---------|------|----------|------|
| `code-explorer` | sonnet | 복잡한 아키텍처 파악 시 opus | 탐색은 보통 중간 수준 |
| `code-architect` | opus | (항상 opus) | 설계 품질은 타협 불가 |
| `code-writer` | **복잡도에 따라** | haiku → sonnet → opus | 위 표 기준으로 자동 선택 |
| `test-architect` | sonnet | 복잡한 엣지케이스 시 opus | 일반적 테스트는 sonnet 충분 |
| `spec-reviewer` | opus | (항상 opus) | 스펙 준수 판단은 정확도 최우선 |
| `quality-reviewer` | opus | (항상 opus) | 보안/품질 리뷰는 정확도 최우선 |
| `code-integrator` | sonnet | 복잡한 충돌 시 opus | 통합은 보통 중간 수준 |

## 위임 패턴

### 1. Prompt Chaining (순차)
```
code-architect 설계 → code-writer 구현(셀프 리뷰) → spec-reviewer → quality-reviewer
```

### 2. Pipeline Parallelization (병렬 파이프라인) ⭐ 권장

#### 분할 방식: 스펙 단위 (수직 분할) 기본

**기본 원칙**: 레이어(엔진/렌더러/UI)별로 나누지 않고, **기능/스펙 단위**로 나눈다.
각 code-writer가 하나의 완결된 기능 전체를 담당하여 맥락 이해도를 높인다.

```
Phase 0: 공통 기반 (1명)
└── types, constants, hooks, utils, 설정 파일, 인터페이스 계약서 (architect의 공유 타입)

Phase 1: 스펙별 병렬 (N명 동시)
├── code-writer #1 — 스펙 A: 기능 A 전체 (상수 + 엔진 + 렌더러 + UI)
├── code-writer #2 — 스펙 B: 기능 B 전체 (상수 + 엔진 + 렌더러 + UI)
└── code-writer #N — 스펙 N: 기능 N 전체 (상수 + 엔진 + 렌더러 + UI)

Phase 2: 연결 (1명)
└── code-writer — reducer, App.jsx, 라우팅, 스펙 간 연결

Phase 3: 검증
└── spec-reviewer → quality-reviewer (순차)
```

**스펙 단위 분할 규칙:**
1. 각 스펙은 **하나의 완결된 기능** (예: "전투 시스템", "인벤토리", "상점")
2. 각 스펙은 **여러 레이어에 걸쳐 파일을 담당** (constants + engine + renderer + component)
3. 스펙 간에 **파일이 절대 겹치지 않게** 설계 — 겹치면 Phase 0나 Phase 2로 이동
4. 공통 파일(타입, 훅, 유틸)은 Phase 0에서 미리 생성
5. 연결 파일(reducer, App, 라우팅)은 Phase 2에서 처리

**RPG 게임 예시:**
| 스펙 | 담당 파일 | 파일 수 |
|------|----------|---------|
| 스펙 A: 캐릭터 시스템 | classes.js, levelup.js, ClassSelect.jsx, LevelUpModal.jsx | 4개 |
| 스펙 B: 맵 탐색 | maps.js, map.js(engine), map.js(renderer), sprites.js, MapScreen.jsx | 5개 |
| 스펙 C: 전투 | battle.js(engine), battle.js(renderer), effects.js, ui-overlay.js, BattleScreen.jsx, SkillBar.jsx | 6개 |
| 스펙 D: 인벤토리/상점 | items.js, inventory.js, shop.js, InventoryPanel.jsx, ShopScreen.jsx | 5개 |
| Phase 2 연결 | reducer.js, App.jsx, main.jsx, HUD.jsx, TitleScreen.jsx, DialogBox.jsx, BattleResultModal.jsx | 7개 |

**스펙 분할 기준 (architect가 판단):**
- 사용자 스토리 단위로 자연스럽게 나뉘는지
- 스펙 간 파일 충돌이 없는지
- 각 스펙이 3-6개 파일 범위인지
- 스펙끼리 의존성이 최소인지

#### 레이어 분할 (수평 분할) — 예외적 사용

스펙 분할이 어려운 경우에만 사용 (예: 모든 기능이 같은 파일을 공유할 때):
- 엔진 / 렌더러 / 컴포넌트 등 레이어별로 분할
- 이 경우 Phase 2 연결 작업이 많아짐

#### 공통 규칙 (두 방식 공통)

**에이전트당 파일 수 제한 (퀄리티 핵심):**
| 파일 수 | 퀄리티 | 권장 |
|---------|--------|------|
| 1-3개 | 최상 | ✅ 권장 |
| 4-6개 | 양호 | 가능 |
| 7-10개 | 저하 | ⚠️ 분할 권장 |
| 10개+ | 낮음 | ❌ 반드시 분할 |

- **code-writer 1명당 3-6개 파일이 적정** — 이 이상은 퀄리티가 급격히 떨어짐
- 한 스펙/파이프라인이 7개+ 파일이면 **2명으로 분할**
- 각 에이전트 프롬프트에 **수정 가능/금지 파일 목록** 명시

### 3. Routing (분류)
단일 에이전트로 처리. 간단한 작업.

### 4. Evaluator-Optimizer (2단계 리뷰 — Superpowers 방식)

**원칙: 스펙 준수 리뷰가 PASS해야 코드 품질 리뷰 시작. 순서 절대 바꾸지 않음.**

```
code-writer 완료
    ↓
Step 0: 셀프 리뷰 (code-writer 자체)
    ├── 자신이 작성한 코드를 Read로 재확인
    ├── 누락된 에러 처리, 하드코딩 값, 미사용 import 체크
    ├── 이슈 발견 → 직접 수정 후 재확인
    └── 이슈 없음 → 다음 단계
    ↓
Step 1: 스펙 준수 리뷰 (spec-reviewer)
    ├── PRD 요구사항이 모두 구현되었는가? (누락 없음)
    ├── 스펙에 없는 기능이 추가되지 않았는가? (초과 없음)
    ├── 에러 시나리오가 모두 처리되었는가?
    ├── 판정: PASS / FAIL (구체적 누락/초과 목록)
    └── FAIL → code-writer 수정 → spec-reviewer 재리뷰
    ↓
Step 2: 코드 품질 리뷰 (quality-reviewer) — Step 1 PASS 후에만
    ├── 보안 이슈 (XSS, injection, 시크릿 노출)
    ├── 성능 이슈 (N+1, 불필요한 리렌더, 메모리 누수)
    ├── 패턴 준수 (기존 코드와 일치하는가)
    ├── 판정: APPROVED / ISSUES (신뢰도 80+만 리포트)
    └── ISSUES → code-writer 수정 → quality-reviewer 재리뷰
    ↓
완료
```

**최대 반복**: 각 단계당 2회, 전체 합산 4회. 4회 도달 시 사용자 보고.

### 5. Orchestrator-Workers (버스트)
```
sj 분석 → code-writer 여럿 스폰 → code-integrator 병합
```
상세: `.claude/memory/team-burst-template.md`

## Agent vs Teammate

| 상황 | 선택 |
|------|------|
| 독립 작업, 단발성 | **Agent** (기본) |
| 병렬 구현 | **Agent** (+ isolation="worktree") |
| 작업 중간 협업 필요 | **Teammate** |

## #2 새 의존성 사전 설치 (sj 책임)
architect 완료 후 Phase F(구현) 전에:
1. architect 출력에서 **"새 의존성"** 섹션 확인
2. 새 패키지가 있으면 sj가 직접 설치: `cd [프로젝트경로] && npm install [패키지@버전]`
3. 설치 실패 시 버전 조정 후 재시도 (최대 2회)
4. writer는 이미 설치된 것으로 간주하고 import만 작성

## #4 DB 스키마 변경 (Phase 0 포함)
스키마 변경이 필요한 작업 시:
1. architect가 **구현 맵에 schema.prisma 수정 포함** (또는 migration 파일)
2. Phase 0(공통 기반)에서 **스키마 수정 + migration 실행**:
   - `schema.prisma` 수정
   - `npx prisma migrate dev --name [기능명]` 실행
   - `npx prisma generate` 실행
3. Phase 1 writers는 **수정된 스키마 기반**으로 구현
4. 마이그레이션 실패 시 sj가 롤백 후 원인 파악

## 위임 프롬프트 필수 항목
1. **역할**: 명확한 역할 정의
2. **범위**: 접근할 파일/디렉토리 명시 (범위 밖 금지)
3. **제약**: 한국어, 범위 밖 수정 금지, **질문 금지 (즉시 실행)** — 정보가 부족하면 최적의 판단으로 진행
4. **출력**: 반환 형식 지정
5. **컨텍스트**: 부모 세션에서 학습한 중요 맥락 포함
6. **결정사항**: 기술 스택, 버전, DB, 환경변수 등 **sj가 미리 결정해서 포함** — 에이전트가 질문할 여지를 없앰
7. **실행 강조**: "반드시 실제 도구로 파일 생성/명령 실행할 것. **파일 생성/수정 시 Edit/Write 대신 Bash `cat >` 명령 사용** (권한 확인 팝업 방지). 보고서만 작성하지 말 것."
8. **스키마 참조**: Prisma/DB 스키마 관련 작업 시 관련 모델 정의를 프롬프트에 포함 — 필드명 불일치 방지
9. **자가 검증**: 파일 생성 후 기본 문법 체크 지시 — "같은 키 중복, 괄호 짝 불일치 등 기본 문법 에러 방지"
10. **CONTEXT.md 활용**: 프로젝트에 `CONTEXT.md`가 있으면 프롬프트에 "작업 전 CONTEXT.md를 읽고 기술 스택/스키마/컨벤션을 파악할 것" 추가. 매번 프롬프트에 전부 적는 대신 파일 참조로 간소화. 템플릿: `rules/context-template.md`

### 위임 프롬프트 템플릿 (필수 사용)
에이전트 스폰 시 **반드시** `rules/delegation-templates.md`의 해당 템플릿을 사용한다.
템플릿 없이 자유 형식으로 위임 금지.

**Verbatim 복사 원칙 (가장 중요):**
- architect/explorer/test-architect의 출력을 sj가 **재작성하거나 요약하지 않음**
- 마크다운 블록을 통째로 `---` 사이에 복사
- 이전 에이전트가 지정한 함수명, 파일 경로, 인터페이스가 누락되면 writer가 정확히 구현 불가
- **"sj의 이해"로 필터링하지 말고 원문 그대로 전달**

## 에이전트 질문 처리 (원천 차단)
```
에이전트 작업 → 질문 반환
  → resume 사용 금지 (이전 컨텍스트 복원으로 혼선 위험)
  → 새 에이전트 스폰 (프롬프트에 답변 포함)
  → 새 에이전트가 즉시 작업 수행
```
- **프롬프트에 "질문 금지, 즉시 실행" 명시** — 1차 방어
- **질문 반환 시 resume 대신 새 스폰** — resume는 이전 컨텍스트 전체를 복원하여 잘못된 작업 이어감
- **사용자에게 에이전트 질문을 그대로 전달하지 않음**
- **sj가 답변한 내용을 사용자에게 요약** — 투명성 유지
- sj가 기술적 결정을 스스로 내림 (버전, DB, 설정값 등)
- 판단 근거: 이전 경험, memory, 안정성 우선

## resume 사용 규칙
- **같은 세션(compact 전)에서만 사용** — compact 이전에 스폰한 에이전트만 resume 가능
- **compact 후 이전 에이전트 ID 사용 금지** — 컨텍스트 초기화로 ID-작업 매핑 상실
- **에이전트 스폰 시 반환된 ID를 즉시 메모 기록** — compact 대비: "Agent ID: xxx (Step N: 역할)"
- **resume로 작업이 어긋나면 즉시 새 스폰으로 전환**

## 에이전트 권한

| 에이전트 | 권한 | 비고 |
|---------|------|------|
| `code-explorer` | Read, Glob, Grep | 읽기 전용 |
| `code-architect` | Read, Glob, Grep | 읽기 전용 |
| `code-writer` | Read, Glob, Grep, Bash | **구현 전담 (파일 생성은 Bash `cat >` 사용)** |
| `test-architect` | Read, Glob, Grep | 읽기 전용 (설계만) |
| `spec-reviewer` | Read, Glob, Grep | 스펙 준수 리뷰 전담 |
| `quality-reviewer` | Read, Glob, Grep | 코드 품질 리뷰 전담 |
| `code-integrator` | Read, Glob, Grep, Bash | 통합/git 전담 |
| `sj` | 전체 | **조율만, 코드 작성 금지** |

## 역할 분리 원칙
- **작성 vs 리뷰 분리**: 같은 에이전트가 작성+리뷰하지 않음
- **스펙 리뷰 vs 품질 리뷰 분리**: spec-reviewer와 quality-reviewer는 독립
- **설계 vs 구현 분리**: architect 설계 → writer 구현
- **범위 충돌 방지**: 다른 에이전트가 같은 파일 동시 수정 금지

## 에이전트 결과물 품질 체크리스트
에이전트 작업 완료 후 sj가 확인:
1. **파일 실제 생성 확인** — 보고서만 쓰고 파일 안 만들었으면 재실행
2. **Prisma 필드명 일치** — 스키마에 없는 필드 사용했는지 확인
3. **문법 에러** — 빌드 실행으로 검증
4. **범위 준수** — 지시하지 않은 파일 수정했는지 확인

## 자동 검증 루프 (파일 생성 강제)
code-writer 완료 후 **반드시** 아래 절차를 자동 실행:

```
code-writer 완료
    ↓
Step 1: 예상 파일 존재 확인
    ls -la <프로젝트경로>/<예상파일들>
    ↓
Step 2: 판정
    ├── 전부 존재 + 비어있지 않음 → 통과, 다음 단계 진행
    ├── 일부 누락 → 누락 파일 목록과 함께 code-writer 재스폰 (시도 1)
    └── 전부 누락 (텍스트만 반환) → "파일을 생성하지 않았음" 명시 후 code-writer 재스폰 (시도 1)
    ↓
Step 3: 재시도 (최대 2회)
    ├── 2회 연속 같은 패턴 실패 → 사용자에게 보고
    │   "code-writer가 2회 연속 파일 생성에 실패했습니다. 접근 방식 변경이 필요할 수 있습니다."
    └── 성공 → 통과
```

**재스폰 프롬프트에 포함할 것:**
- "이전 시도에서 파일을 생성하지 않고 텍스트만 반환했습니다. **반드시 Bash cat > 로 실제 파일을 생성하세요.**"
- 이전 시도에서 반환한 텍스트 내용 (있으면 참고용으로)
- 누락된 파일 경로 목록

**주의사항:**
- **resume 사용 금지** — 재시도는 항상 새 에이전트 스폰
- **사용자에게 묻지 않음** — 자동 검증/재시도는 sj가 알아서, 결과만 보고
- **2회 초과 시 중단** — 같은 방식으로 3번 실패하면 근본 원인이 다름

## architect 출력 품질 자동 검증
architect 완료 후 **반드시** 아래 항목 확인:

```
architect 완료
    ↓
Step 1: 출력에 아래 섹션이 모두 있는지 확인
    ├── 인터페이스 계약서 (타입 정의 + 함수 시그니처)
    ├── 핵심 로직 의사코드
    ├── 에러 시나리오 테이블
    ├── 기존 코드 참조 (file:line 형식)
    ├── 구현 제약사항 (금지/강제)
    └── 구현 맵 (파일 목록)
    ↓
Step 2: 기존 코드 참조가 실제 존재하는지 확인
    ls -la [참조한 파일 경로]
    ↓
Step 3: 판정
    ├── 필수 섹션 누락 → "누락된 섹션: [목록]" 명시 후 재스폰 (최대 1회)
    └── 전부 충족 → 통과, writer에게 전달
```

## 하위 호환성
- `isolation="worktree"`: 일반 스폰에서만 작동, 팀 스폰에서는 수동 worktree 생성 필요
