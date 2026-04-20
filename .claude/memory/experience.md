# 경험 기반 학습 (Experiential Learning)

> 작업 방식 선택 단계에서 참고하는 실패/성공 이력.
> 새 세션 시작 시 이 파일을 체크하여 go-to 방식을 우선 적용한다.
> 기록 규칙: 실패 3회 누적 → 인사이트로 일반화 → CLAUDE.md 규칙화 제안

---

## 작성 포맷

```
## 카테고리: [작업 유형]
- ❌ [방식/도구]: [실패 이유] (X회 실패) → reflexion: "[왜 실패했는지]"
- ✅ [방식/도구] → go-to
- 인사이트: "[일반화된 교훈]"
```

---

## 카테고리: PDF 생성 (2026-04-15)
- ✅ puppeteer-core + Chrome + HTML → go-to
- 비고: macOS에 Chrome 설치된 경우 puppeteer-core만으로 충분 (Chromium 다운로드 불필요)
- 비고: Google Fonts (@import) 사용 시 `waitUntil: 'networkidle0'` + `document.fonts.ready` 대기 필수
- 비고: `printBackground: true` 설정해야 CSS 배경색/그라데이션 정상 출력
- ❌ subdirectory에서 Write 시 hook 경로 문제: `.claude/hooks/` 상대 경로가 CWD 기준 → 항상 프로젝트 루트에서 Write 실행 필요
- 인사이트: "PDF 생성은 HTML+CSS로 디자인 후 puppeteer-core로 변환이 가장 유연. Chrome 설치된 환경이면 puppeteer-core만으로 충분"

<!-- 아래는 삭제하지 마세요. 새 경험 기록 시 이 위에 추가하세요. -->
