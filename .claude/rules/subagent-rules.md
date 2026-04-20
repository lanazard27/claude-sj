# Sub-agent 위임 규칙

## Routing (요청 분류)

| 요청 유형 | 에이전트 | 모델 | 언제 |
|----------|---------|------|------|
| 코드베이스 탐색 | `code-explorer` | opus | 유사 기능 찾기, 구조 파악 |
| 아키텍처 설계 | `code-architect` | opus | 청사인, 설계 결정 |
| 코드 구현/수정 | `code-writer` | opus | 스펙 기반 구현, 버그 수정 |
| 테스트 케이스 설계 | `test-architect` | opus | 엣지 케이스, 테스트 명세 |
| 코드 리뷰/검증 | `dev-reviewer` | opus | 품질 게이트, 보안 리뷰 |
| 결과물 병합 | `code-integrator` | opus | 병렬 작업 통합, 충돌 해결 |

## 복잡도 기반 스마트 라우팅

작업 복잡도에 따라 자동으로 에이전트 조합 결정:

| 복잡도 | 판단 기준 | 워크플로우 |
|--------|----------|------------|
| 단순 | 1-2파일, 기존 패턴 있음 | code-writer만 |
| 중간 | 3-5파일, 신규 기능 | PRD → architect → writer → reviewer |
| 복잡 | 5파일+, 다중 기능 | PRD → architect(스펙 분할) → Phase 0(공통) → **writers 스펙별 병렬(3-6파일씩)** → writer(연결) → reviewer |
| 보안 | 인증/권한/결제 관련 | PRD → architect → writer → reviewer(2회) |
| 테스트 | 테스트 커버리지 강화 | test-architect(설계) → writer(구현) → reviewer(검증) |

## 모델 승격

| 에이전트 | 기본 | 비고 |
|---------|------|------|
| `code-explorer` | opus | 탐색 정확도 최우선 |
| `code-architect` | opus | 설계 품질 최우선 |
| `code-writer` | opus | 구현 품질 최우선 |
| `test-architect` | opus | 테스트 설계 품질 최우선 |
| `dev-reviewer` | opus | 리뷰 정확도 최우선 |
| `code-integrator` | opus | 통합 안정성 최우선 |

## 위임 패턴

### 1. Prompt Chaining (순차)
```
code-architect 설계 → code-writer 구현 → dev-reviewer 검증
```

### 2. Pipeline Parallelization (병렬 파이프라인) ⭐ 권장

#### 분할 방식: 스펙 단위 (수직 분할) 기본

**기본 원칙**: 레이어(엔진/렌더러/UI)별로 나누지 않고, **기능/스펙 단위**로 나눈다.
각 code-writer가 하나의 완결된 기능 전체를 담당하여 맥락 이해도를 높인다.

```
Phase 0: 공통 기반 (1명)
└── types, constants, hooks, utils, 설정 파일

Phase 1: 스펙별 병렬 (N명 동시)
├── code-writer #1 — 스펙 A: 기능 A 전체 (상수 + 엔진 + 렌더러 + UI)
├── code-writer #2 — 스펙 B: 기능 B 전체 (상수 + 엔진 + 렌더러 + UI)
└── code-writer #N — 스펙 N: 기능 N 전체 (상수 + 엔진 + 렌더러 + UI)

Phase 2: 연결 (1명)
└── code-writer — reducer, App.jsx, 라우팅, 스펙 간 연결

Phase 3: 검증
└── dev-reviewer — 전체 리뷰
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

### 4. Evaluator-Optimizer (피드백)
```
code-writer → dev-reviewer → 이슈 발견 → code-writer 수정 → 재리뷰 (최대 3회)
```

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
| `dev-reviewer` | Read, Glob, Grep | 리뷰 전담 |
| `code-integrator` | Read, Glob, Grep, Bash | 통합/git 전담 |
| `sj` | 전체 | **조율만, 코드 작성 금지** |

## 역할 분리 원칙
- **작성 vs 리뷰 분리**: 같은 에이전트가 작성+리뷰하지 않음
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

## 하위 호환성
- `isolation="worktree"`: 일반 스폰에서만 작동, 팀 스폰에서는 수동 worktree 생성 필요
