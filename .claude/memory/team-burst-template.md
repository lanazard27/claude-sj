# 병렬 구현 매뉴얼 (Agent 스폰 방식)

> Teammate 대신 Agent 스폰 방식 사용.
> 상세 규칙은 `rules/subagent-rules.md` Pipeline Parallelization 참조.

## 라이프사이클
```
[1인] 정보수집 → PRD 작성 → 사용자 승인
[설계] code-architect: 스펙 단위 분할 + 파일 배정
[Phase 0] code-writer 1명: 공통 기반 (types, constants, hooks, utils)
[Phase 1] code-writer N명: 스펙별 병렬 (각 3-6파일)
[Phase 2] code-writer 1명: 연결 (reducer, App, 라우팅)
[검증] 셀프 리뷰 → spec-reviewer → quality-reviewer → 빌드/테스트
```

## 트리거 조건
- 3파일+ 작업 (PRD 작성 기준)
- 5파일+ → 스펙 분할 + 병렬
- 사용자가 명시적 요청

## 스펙 분할 (architect 담당)
1. PRD를 기능 단위(스펙)로 분할
2. 각 스펙에 파일 배정 (3-6개, 겹치지 않게)
3. 공통 파일은 Phase 0으로 분리
4. 연결 파일은 Phase 2로 분리
5. 스펙 분할표를 반환 (스펙명 | 파일목록 | 파일수)

## Phase 0: 공통 기반 (1명)
- 프로젝트 스캐폴딩 (Vite, Next.js 등)
- types/index.js — 공통 타입 정의
- constants/ — 공통 상수 데이터
- hooks/ — 공통 훅
- utils/ — 공통 유틸
- 빌드 검증

## Phase 1: 스펙별 병렬 (N명)
- 각 code-writer에 `mode: "dontAsk"` 스폰
- 프롬프트에 포함:
  - PRD (해당 스펙 요구사항 + 에러 시나리오)
  - 아키텍처 설계 (파일 구조, 인터페이스)
  - 참고 구현체 (있으면)
  - UI 디자인 참고 (프론트엔드면)
  - 테스트 명세
  - **수정 가능/금지 파일 목록**
  - **"Bash cat > 사용, 상태 반환 필수 (DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED)"**
- 각 code-writer는 빌드 검증 + 셀프 리뷰까지 수행
- 파일 누락 시 재스폰 (resume 금지)

## Phase 2: 연결 (1명)
- reducer.js, App.jsx, main.jsx, 라우팅
- 스펙 간 인터페이스 연결
- import 경로 정리
- 통합 빌드 검증

## 검증
- 10파일 이하: spec-reviewer → quality-reviewer (순차)
- 10파일+:
  - Per-pipeline 리뷰: 각 파이프라인 spec-reviewer → quality-reviewer
  - 통합 리뷰: spec-reviewer → quality-reviewer (순차)
- 빌드 + 테스트

## 실패 시 대응
- 빌드 실패: code-writer 재수정 (최대 3회)
- 같은 에러 2회: 접근 방식 변경
- 5회 도달: 사용자 보고

## 실전 교훈
- **에이전트당 3-6파일이 적정** — 7개+ 품질 급락
- **스펙 단위 분할이 레이어 분할보다 품질 높음** — 맥락 이해도 향상
- **Phase 0 공통 파일이 탄탄해야 Phase 1이 원활** — 타입/상수가 계약서 역할
- **병렬 3개+ 스폰 시 파일 누락 주의** — 보고서만 쓰고 cat > 생략하는 케이스
- **프롬프트에 "수정 금지 파일 목록" 명시 필수** — 범위 위반이 가장 흔한 문제
