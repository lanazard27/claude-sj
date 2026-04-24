# Sub-agent 위임 규칙

## Token Budget
에이전트 스폰 시 출력 토큰 관리.
| 에이전트 | max_turns | 이유 |
|---------|-----------|------|
| code-explorer | 15 | 빠르게, 필요시 재스폰 |
| code-architect | 20 | 신중하게, 불필요한 반복 금지 |
| code-writer(단순) | 15 | sonnet 권장(haiku 파일 생성 누락 잦음), 1-2파일 |
| code-writer(중간) | 20 | 3-5파일, 셀프 리뷰 포함 |
| code-writer(복잡) | 30 | 5파일+, 설계 판단 필요 |
| spec-reviewer | 10 | 리뷰만, 수정은 writer |
| quality-reviewer | 10 | 리뷰만 |
| test-architect | 15 | 설계만 |
| code-integrator | 20 | 병합+빌드 검증 |

**sj 체크**: 응답 5K+ 토큰 시 다음 스폰에서 프롬프트 구체화하여 범위 축소.

## Routing
| 요청 유형 | 에이전트 | 모델 | 복잡도 | 워크플로우 |
|----------|---------|------|--------|----------|
| 코드베이스 탐색 | code-explorer | sonnet | 중간 | 유사 기능, 구조 파악 |
| 아키텍처 설계 | code-architect | opus | 복잡 | 청사진, 설계 결정 |
| 구현(단순) | code-writer | sonnet | 단순 | 1-2파일, 기존 패턴. **haiku 파일 생성 누락 위험** |
| 구현(중간) | code-writer | sonnet | 중간 | 3-5파일, 약간 판단 |
| 구현(복잡) | code-writer | opus | 복잡 | 5파일+, 설계 판단 |
| 테스트 설계 | test-architect | sonnet | 중간 | 엣지 케이스, 테스트 명세 |
| 스펙 준수 리뷰 | spec-reviewer | opus | 복잡 | PRD-구현 일치 |
| 코드 품질 리뷰 | quality-reviewer | opus | 복잡 | 보안, 성능, 패턴 |
| 결과물 병합 | code-integrator | sonnet | 중간 | 병렬 통합, 충돌 해결 |

**복잡도 워크플로우**: 단순→writer만 / 중간→PRD→architect→writer→reviewer / 복잡→PRD→architect(스펙분할)→Phase0→writers병렬(3-6파일씩)→writer(연결)→reviewer / 보안→reviewer(2회) / 테스트→test-architect→writer→reviewer

## 모델 승격
**기본 원칙**: 가장 약한 모델로 시작, 필요시 승격.
| 복잡도 | 판단 신호 | 모델 | 예시 |
|--------|----------|------|------|
| 단순 | 1-2파일, 명확한 스펙, 기존 패턴 | sonnet | 버튼 추가, API 1개, 상수 |
| 중간 | 3-5파일, 약간 판단, 새 기능 | sonnet | 컴포넌트, 미들웨어, 훅 |
| 복잡 | 5파일+, 설계 판단, 다중 연동 | opus | 아키텍처, 상태관리, 보안 |

**에이전트별 기본 모델**: code-explorer(sonnet→opus), code-architect(opus), code-writer(복잡도에 따라), test-architect(sonnet→opus), spec-reviewer(opus), quality-reviewer(opus), code-integrator(sonnet→opus). **haiku는 파일 생성 누락 위험으로 사용 금지.**

## 위임 패턴

### 1. Prompt Chaining (순차)
`code-architect → code-writer(셀프 리뷰) → spec-reviewer → quality-reviewer`

### 2. Pipeline Parallelization (병렬 파이프라인)
**스펙 단위 분할**: 레이어별이 아닌 기능/스펙 단위로 분할. 각 writer가 완결된 기능 전체 담당.
```
Phase 0: 공통 기반(1명) → types, constants, hooks, utils, 설정, 인터페이스 계약서
Phase 1: 스펙별 병렬(N명) → 각 스펙 전체 (상수+엔진+렌더러+UI)
Phase 2: 연결(1명) → reducer, App.jsx, 라우팅, 연결
Phase 3: 검증 → spec-reviewer → quality-reviewer
```
**분할 규칙**: 각 스펙=완결된 기능, 여러 레이어 담당, 스펙 간 파일 겹침 금지, 공통은 Phase 0, 연결은 Phase 2
**분할 기준**: 사용자 스토리 단위, 스펙 간 충돌 없음, 각 스펙 3-6개 파일, 의존성 최소
**사전 검증(sj)**: 파일 중복? 숨은 의존성? 각 스펙 3-6개? Phase 2 연결 복잡도 10+면 순차 전환

#### 에이전트당 파일 수 제한
| 파일 수 | 퀄리티 | 권장 |
|---------|--------|------|
| 1-3개 | 최상 | ✅ |
| 4-6개 | 양호 | 가능 |
| 7-10개 | 저하 | ⚠️ 분할 권장 |
| 10개+ | 낮음 | ❌ 반드시 분할 |

**code-writer 1명당 3-6개 적정**, 7+면 분할 (수정 가능/금지 파일 목록 명시)

### 3. Routing (분류)
단일 에이전트로 처리. 간단한 작업.

### 4. Evaluator-Optimizer (2단계 리뷰)
**원칙: 스펙 준수 PASS 후 품질 리뷰. 순서 절대 변경 불가.**
- Step 0: 셀프 리뷰 — Read로 재확인, 누락/하드코딩/미사용 import 체크, 이슈 시 직접 수정
- Step 1: 스펙 준수 — PRD 요구사항 모두 구현, 초과 없음, 에러 처리, PASS/FAIL
- Step 2: 코드 품질 — Step 1 PASS 후만, 보안/성능/패턴, APPROVED/ISSUES
**최대 반복**: 각 단계 2회, 전체 4회. 4회 도달 시 사용자 보고.

### 5. Orchestrator-Workers (버스트)
`sj 분석 → code-writer 여럿 스폰 → code-integrator 병합`. 상세: `.claude/memory/team-burst-template.md`

## Agent vs Teammate
| 상황 | 선택 |
|------|------|
| 독립 작업, 단발성 | Agent |
| 병렬 구현 | Agent (+ isolation="worktree") |
| 작업 중간 협업 필요 | Teammate |

## 에이전트 상태 관리
모든 에이전트는 완료 후 반드시 아래 상태 중 하나 반환:
| 상태 | 의미 | sj 대응 |
|------|------|---------|
| DONE | 완료, 이슈 없음 | 다음 단계 |
| DONE_WITH_CONCERNS | 완료, 우려 있음 | 검토 후 진행, 문제면 수정 |
| NEEDS_CONTEXT | 정보 부족 | 정보 제공 후 새 스폰 |
| BLOCKED | 근본적 차단 | 컨텍스트 보충/모델 승격/분할/에스컬레이션 |

**BLOCKED 처리**: 1)컨텍스트 문제→정보 제공 후 새 스폰 2)능력 부족→상위 모델 승격 후 새 스폰 3)태스크 과대→분할 후 재스폰 4)설계 오류→사용자 에스컬레이션
**절대 금지**: 같은 모델/프롬프트로 재시도, BLOCKED 무시하고 강제 진행

### BLOCKED 에스컬레이션 보고서
사용자에게 전달: **문제**(막힌 지점) / **시도**(해본 방법) / **필요 결정**(사용자 선택 옵션) / **sj 제안**(대안)

### DONE_WITH_CONCERNS 자동 분류
| 카테고리 | 판단 기준 | sj 대응 |
|---------|----------|---------|
| 진행 가능 | "파일 길어짐", "리팩토링하면 좋겠음" | 기록 후 진행 |
| 검토 필요 | "패턴 다름", "확신 없음" | sj가 Read로 확인 후 진행 |
| 수정 필요 | "요구사항 일부만", "에러 누락" | FAIL과 동일, 수정 지시 |

**분류 원칙**: 애매하면 한 단계 아래로, 사용자에게 간단히 보고

## 새 의존성 사전 설치 (sj 책임)
architect 완료 후 Phase F 전: 1)architect 출력에서 "새 의존성" 확인 2)sj가 직접 설치(`cd [경로] && npm install [패키지@버전]`) 3)실패 시 버전 조정 후 재시도(최대 2회) 4)writer는 설치된 것으로 간주하고 import만 작성

## DB 스키마 변경 (Phase 0 포함)
1)architect가 구현 맵에 schema.prisma 수정 포함 2)Phase 0에서 스키마 수정+마이그레이션: schema.prisma 수정 → `npx prisma migrate dev --name [기능명]` → `npx prisma generate` 3)Phase 1 writers는 수정된 스키마 기반 구현 4)마이그레이션 실패 시 sj가 롤백 후 원인 파악

## 위임 프롬프트 필수 항목
1. **역할**: 명확한 정의 2. **범위**: 접근할 파일/디렉토리 (범위 밖 금지) 3. **제약**: 한국어, 범위 밖 수정 금지, 정보 부족 시 질문 가능(기술 스택/아키텍처 결정 제외) 4. **출력**: 반환 형식 + **상태 반환 필수**(DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED) 5. **컨텍스트**: 부모 세션 학습 맥락 6. **결정사항**: sj가 미리 결정한 기술 선택(버전, DB, 환경변수) 7. **실행 강조**: "반드시 실제 도구로 파일 생성. **Bash `cat >` 사용**(권한 팝업 방지). 보고서만 작성 금지." 8. **스키마 참조**: Prisma/DB 스키마 작업 시 관련 모델 정의 포함(필드명 불일치 방지) 9. **자가 검증**: 파일 생성 후 기본 문법 체크(같은 키 중복, 괄호 짝 등) 10. **CONTEXT.md 활용**: 프로젝트에 CONTEXT.md 있으면 "작업 전 읽고 스택/스키마/컨벤션 파악" 추가

### 위임 프롬프트 템플릿 (필수 사용)
에이전트 스폰 시 **반드시** `rules/delegation-templates.md` 해당 템플릿 사용. 자유 형식 위임 금지. Verbatim 복사 원칙은 delegation-templates.md 공통 규칙 참조.

## 에이전트 질문 처리 (제한적 허용)
**원칙: 막히면 질문하게 두는 것이 잘못된 작업보다 낫다.**
- 작업 시작 전 질문 → sj가 즉시 답변 → 같은 에이전트 계속 진행
- 작업 중 막힘 → NEEDS_CONTEXT 반환 → sj가 정보 제공 후 새 스폰
**허용 범위**: 파일 경로, 스키마 필드명, 기존 패턴 위치, API 엔드포인트 형식. **불가**: 기술 스택 선택, 아키텍처 결정, 라이브러리 버전(sj가 결정)
**sj 대응**: 1)에이전트 질문 읽고 sj가 직접 답변(사용자 전달 안 함) 2)근거: 경험, memory, 컨텍스트, 안정성 우선 3)답변 포함해 새 스폰(resume 금지) 4)사용자에게는 "에이전트가 X 질문해서 Y 답변했어" 요약

## resume 사용 규칙
- **같은 세션(compact 전)에서만** — compact 후 ID-작업 매핑 상실
- **질문 처리 시에도 resume 금지** — 항상 새 스폰

## 에이전트 권한
| 에이전트 | 권한 | 비고 |
|---------|------|------|
| code-explorer | Read, Glob, Grep | 읽기 전용 |
| code-architect | Read, Glob, Grep | 읽기 전용 |
| code-writer | Read, Glob, Grep, Bash | **구현 전담(Bash `cat >` 사용)** |
| test-architect | Read, Glob, Grep | 읽기 전용(설계만) |
| spec-reviewer | Read, Glob, Grep | 스펙 준수 리뷰 전담 |
| quality-reviewer | Read, Glob, Grep | 코드 품질 리뷰 전담 |
| code-integrator | Read, Glob, Grep, Bash | 통합/git 전담 |
| sj | 전체 | **조율만, 코드 작성 금지** |

## 전문 도메인 에이전트 (선택적)
`~/.claude/agents/`의 도메인 에이전트를 sj 기본 에이전트로 커버 안 되는 영역에 활용.
**매핑**: 보안(@security-engineer) / DevOps(@devops-architect) / 성능(@performance-engineer) / 비즈니스(@business-panel-experts) / 근원 원인(@root-cause-analyst) / 요구사항(@requirements-analyst) / 기술 문서(@technical-writer) / 학습(@learning-guide, @socratic-mentor) / 저장소(@repo-index) / 리팩토링(@refactoring-expert) / Python(@python-expert)
**원칙**: 보조 도구(sj 기본이 주축), 필요시만 호출, sj가 조율, 상태 반환 동일

## 역할 분리 원칙
- **작성 vs 리뷰 분리**: 같은 에이전트가 작성+리뷰하지 않음
- **스펙 리뷰 vs 품질 리뷰 분리**: spec-reviewer와 quality-reviewer는 독립
- **설계 vs 구현 분리**: architect 설계 → writer 구현
- **범위 충돌 방지**: 다른 에이전트가 같은 파일 동시 수정 금지

## 에이전트 결과물 품질 체크리스트
완료 후 sj 확인: 1)파일 실제 생성 확인(보고서만 쓰고 파일 안 만들었으면 재실행) 2)Prisma 필드명 일치 3)문법 에러(빌드로 검증) 4)범위 준수

## 자동 검증 루프 (파일 생성 강제)
code-writer 완료 후: 파일 존재 확인(`ls -la`) → 누락 시 재스폰(최대 2회) → 2회 실패 시 사용자 보고.
**재스폰 시**: "Bash cat >로 실제 파일 생성" 강조 + 누락 파일 목록 전달. resume 금지, 사용자 묻지 않음.

## architect 출력 품질 자동 검증
필수 섹션(계약서/의사코드/에러표/참조/제약/맵) 확인 + 참조 파일 존재(`ls -la`) 확인. 누락 시 재스폰(최대 1회), 충족 시 writer에게 전달.

## 하위 호환성
- `isolation="worktree"`: 일반 스폰에서만 작동, 팀 스폰에서는 수동 worktree 생성 필요

## 장시간 에이전트 실행 (--worktree + --tmux)
- `claude --worktree feature-name --tmux`: 터미널 닫아도 에이전트 유지
- 장시간 작업(10분+) 필요 시 sj가 제안
- worktree 내 변경사항은 완료 후 메인 브랜치로 병합
