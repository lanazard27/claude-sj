# 팀 버스트 운영 매뉴얼 (요약판)

## 라이프사이클
```
[1인] 정보수집 완료 → 버스트 제안 → 사용자 승인
[Pre-Burst] code-explorer 컨벤션 수집 → 작업 분해 → worktree 생성 → 프롬프트 빌드
[Burst]    TeamCreate → 팀원 스폰 → 조율 → dev-reviewer 검증
[Merge]    범위 검증 → 순차 병합 → 통합 빌드
[Post]     TeamDelete → 브랜치 정리 → 1인 복귀
```

## 트리거 조건
- 작업이 2+ 독립 영역으로 분리 가능
- 각 영역이 다른 파일 그룹 사용
- 병렬 시 체감 시간 단축 의미 있음
- 또는 사용자가 명시적 요청

## 팀 구성
```
sj (team-lead) — 순수 조율자 (코드 작성 X)
  ├─ fe-dev (opus, general-purpose) — 프론트엔드
  ├─ be-dev (opus, general-purpose) — 백엔드
  └─ dev-reviewer (opus, 읽기 전용) — 검증
```

## Pre-Burst 체크리스트
- [ ] code-explorer로 컨벤션 수집 (파일 구조, 네이밍, import, 스타일 패턴)
- [ ] 팀원별 담당 영역과 **파일 범위 엄격 분리**
- [ ] worktree 수동 생성:
  ```
  git branch burst/{role}-{기능명} main
  git worktree add .burst/{role} burst/{role}-{기능명}
  cd .burst/{role} && ln -s ../../node_modules node_modules
  ```
- [ ] 프롬프트에 파일 범위 + 완료 기준 + 컨벤션 주입

## 팀원 프롬프트 핵심 규칙
- **파일 범위 절대 준수**: 수정 가능 목록에 있는 파일만 수정
- **import 추가/수정도 파일 수정에 해당** — 범위 밖 파일 import 변경 금지
- **빌드 에러가 범위 밖에서 발생하면 수정하지 말고 team-lead에게 보고**
- 승인 없이 바로 구현, team-lead에게 질문 금지
- 완료 시 변경 파일 목록 + 빌드 결과 전송

## Burst 중 sj 역할
- O: 완료 보고 수신, dev-reviewer 호출, 진행 상황 보고
- X: 직접 코드 작성, 팀원 코드 임의 수정, 사소한 질문 응답

## Merge 체크리스트
- [ ] **각 브랜치 범위 위반 검증**: `git diff --name-only main...burst/{branch}`
- [ ] 순차 병합 (fe 먼저 → 빌드 → be → 빌드)
- [ ] 충돌 시: 간단하면 해결, 복잡하면 사용자 개입
- [ ] 통합 빌드 테스트

## 실패 시 롤백
- 전체 실패: `git merge --abort` → 브랜치 전체 폐기 → 1인 재도전
- 부분 실패: 성공한 것만 유지, 실패 부분은 1인으로

## Post-Burst
- [ ] 팀원 shutdown → TeamDelete
- [ ] worktree 정리: `git worktree remove .burst/{role} --force`
- [ ] 브랜치 정리 (성공: -d / 실패: -D)
- [ ] 결과 요약 보고 → WIP 업데이트

## 실전 교훈
- `isolation="worktree"`는 팀 스폰에서 미작동 → sj가 수동 생성
- `mode="bypassPermissions"`는 팀 스폰에서도 정상 작동
- **범위 위반이 가장 흔한 문제**: be-dev가 fe 영역 파일을 수정한 사례 다수 → 프롬프트에 강조 필수
- 병렬 Writer가 같은 파일 수정하면 일관성 깨짐 → UI 컴포넌트는 항상 1명
