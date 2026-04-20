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

| 복잡도 | 판단 기준 | 에이전트 조합 |
|--------|----------|--------------|
| 단순 | 1-2파일, 기존 패턴 있음 | code-writer만 |
| 중간 | 3-5파일, 신규 기능 | explorer → architect → writer → reviewer |
| 복잡 | 5파일+, 다중 시스템 연동 | explorer → architect → writer(다수) → test-architect → reviewer → integrator |
| 보안 | 인증/권한/결제 관련 | explorer → architect → writer → reviewer(2회) |
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

### 2. Parallelization (병렬)
```
sj (Orchestrator)
├── code-writer #1 — 영역 A
├── code-writer #2 — 영역 B (파일 범위 겹치지 않아야 함)
```

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

## 하위 호환성
- `isolation="worktree"`: 일반 스폰에서만 작동, 팀 스폰에서는 수동 worktree 생성 필요
