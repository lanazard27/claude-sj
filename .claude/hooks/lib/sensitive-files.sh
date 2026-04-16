#!/bin/bash
# lib/sensitive-files.sh — 민감 파일 검증 공통 로직
# pre-file-check.sh (Write|Edit)과 pre-read-check.sh (Read)에서 source하여 사용.
#
# 사용법:
#   source "$(dirname "$0")/lib/sensitive-files.sh"
#   check_sensitive "$FILE_PATH" "$ACTION_LABEL"
#
# 인자:
#   $1 = FILE_PATH (절대 경로)
#   $2 = ACTION_LABEL ("읽기" 또는 "쓰기/수정")
#
# 반환:
#   0 = 허용, 2 = 차단 (stderr에 사유 출력)

check_sensitive() {
  local FILE_PATH="$1"
  local ACTION_LABEL="$2"
  local BASENAME

  BASENAME=$(basename "$FILE_PATH" 2>/dev/null || echo "")

  # ============================================================
  # 1. 절대 차단 — 시크릿/인증서/환경변수 파일
  # ============================================================
  local BLOCKED_EXACT=(
    ".env"
    ".env.local"
    ".env.development"
    ".env.production"
    ".env.staging"
    ".env.test"
    "credentials.json"
    "service-account.json"
    "id_rsa"
    "id_ed25519"
    "id_ecdsa"
    ".htpasswd"
    ".netrc"
  )

  local blocked
  for blocked in "${BLOCKED_EXACT[@]}"; do
    if [ "$BASENAME" = "$blocked" ]; then
      echo "BLOCKED: 민감 파일 '$BASENAME' ${ACTION_LABEL} 차단되었습니다 — 시크릿 보호" >&2
      return 2
    fi
  done

  # ============================================================
  # 2. 확장자 기반 차단 — 인증서/키 파일
  # ============================================================
  local BLOCKED_EXTENSIONS=(
    ".pem"
    ".key"
    ".p12"
    ".pfx"
    ".jks"
    ".keystore"
  )

  local ext
  for ext in "${BLOCKED_EXTENSIONS[@]}"; do
    case "$BASENAME" in
      *"$ext")
        echo "BLOCKED: 인증서/키 파일 '$BASENAME' ${ACTION_LABEL} 차단되었습니다 — 보안 인증서 보호" >&2
        return 2
        ;;
    esac
  done

  # ============================================================
  # 3. .env.* 패턴 매칭
  # ============================================================
  case "$BASENAME" in
    .env.*)
      echo "BLOCKED: 환경 변수 파일 '$BASENAME' ${ACTION_LABEL} 차단되었습니다 — 시크릿 보호" >&2
      return 2
      ;;
  esac

  # ============================================================
  # 4. 보안 디렉토리 하위 파일 차단
  # ============================================================
  if echo "$FILE_PATH" | grep -qiE "/(\.ssh|\.gnupg|secrets|credentials)/"; then
    echo "BLOCKED: 보안 디렉토리 내 파일 '$FILE_PATH' ${ACTION_LABEL} 차단" >&2
    return 2
  fi

  # ============================================================
  # 5. .claude 내부 파일 차단 (읽기 전용)
  # ============================================================
  if [ "$ACTION_LABEL" = "읽기" ]; then
    if echo "$FILE_PATH" | grep -qE "/\.claude/(logs|security-state)/"; then
      echo "BLOCKED: 시스템 내부 파일 '$FILE_PATH' 읽기 차단" >&2
      return 2
    fi
  fi

  return 0
}
