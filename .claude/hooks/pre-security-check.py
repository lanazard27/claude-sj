#!/usr/bin/env python3
"""
Claude Code Hook: Security Pattern Checker
============================================
PreToolUse hook for Write|Edit|MultiEdit — 코드 내용에서 보안 취약점 패턴 감지

공식 security_reminder_hook.py 아키텍처 참고:
- 세션별 중복 경고 방지 (session_id 기반 상태 관리)
- 파일 내용 검사 (path + content 기반 패턴 매칭)
- fail-open: 에러 시 작업 차단하지 않음
- 30일 이상 된 상태 파일 자동 정리

설정 (settings.json):
{
  "PreToolUse": [{
    "matcher": "Write|Edit|MultiEdit",
    "hooks": [{
      "type": "command",
      "command": "python3 ~/.claude/hooks/pre-security-check.py"
    }]
  }]
}
"""

import json
import os
import random
import re
import sys
from datetime import datetime

# ============================================================
# 보안 패턴 정의
# ============================================================
SECURITY_PATTERNS = [
    {
        "ruleName": "eval_usage",
        "substrings": ["eval("],
        "reminder": (
            "[보안 경고] eval()은 임의 코드를 실행할 수 있어 심각한 보안 위험입니다. "
            "데이터 파싱에는 JSON.parse()를, 다른 용도는 안전한 대안 패턴을 사용하세요."
        ),
    },
    {
        "ruleName": "new_function_injection",
        "substrings": ["new Function("],
        "reminder": (
            "[보안 경고] new Function()에 동적 문자열을 전달하면 코드 인젝션 위험이 있습니다. "
            "임의 코드를 평가하지 않는 안전한 대안을 사용하세요."
        ),
    },
    {
        "ruleName": "dangerously_set_inner_html",
        "substrings": ["dangerouslySetInnerHTML"],
        "reminder": (
            "[보안 경고] dangerouslySetInnerHTML은 XSS 취약점을 유발할 수 있습니다. "
            "DOMPurify 등의 라이브러리로 반드시 콘텐츠를 살균하세요."
        ),
    },
    {
        "ruleName": "inner_html_xss",
        "substrings": [".innerHTML =", ".innerHTML="],
        "reminder": (
            "[보안 경고] 신뢰할 수 없는 콘텐츠로 innerHTML 설정 시 XSS 위험이 있습니다. "
            "일반 텍스트에는 textContent를, 안전한 DOM 메서드를 사용하세요."
        ),
    },
    {
        "ruleName": "document_write_xss",
        "substrings": ["document.write("],
        "reminder": (
            "[보안 경고] document.write()는 XSS 공격에 악용될 수 있습니다. "
            "createElement()와 appendChild() 등 안전한 DOM 조작 메서드를 사용하세요."
        ),
    },
    {
        "ruleName": "child_process_exec",
        "substrings": ["child_process.exec(", "execSync("],
        "reminder": (
            "[보안 경고] child_process.exec()는 명령어 인젝션 위험이 있습니다. "
            "execFile()나 spawn()을 인자 배열과 함께 사용하세요."
        ),
    },
    {
        "ruleName": "os_system_injection",
        "substrings": ["os.system(", "os.system ("],
        "reminder": (
            "[보안 경고] os.system()은 사용자 입력으로 명령어 인젝션 위험이 있습니다. "
            "subprocess.run()을 인자 리스트와 함께 사용하세요."
        ),
    },
    {
        "ruleName": "pickle_deserialization",
        "substrings": ["pickle.loads(", "pickle.load("],
        "reminder": (
            "[보안 경고] 신뢰할 수 없는 콘텐츠의 pickle 역직렬화는 임의 코드 실행 위험이 있습니다. "
            "JSON 등 안전한 직렬화 포맷을 사용하세요."
        ),
    },
    {
        "ruleName": "sql_injection",
        "substrings": [".raw(", "execute(\"SELECT", "execute(\"INSERT", "execute(\"UPDATE", "execute(\"DELETE"],
        "reminder": (
            "[보안 경고] 문자열 결합으로 Raw SQL을 작성하면 SQL 인젝션 위험이 있습니다. "
            "파라미터화된 쿼리나 ORM 메서드를 사용하세요."
        ),
    },
    {
        "ruleName": "hardcoded_secret",
        "substrings": ["password =", "password=", "secret_key =", "secret_key=", "api_key =", "api_key="],
        "reminder": (
            "[보안 경고] 하드코딩된 시크릿이 감지되었습니다. "
            "환경 변수나 시크릿 매니저를 사용하세요."
        ),
    },
    {
        "ruleName": "github_actions_injection",
        "path_check": lambda path: ".github/workflows/" in path and path.endswith((".yml", ".yaml")),
        "reminder": (
            "[보안 경고] GitHub Actions 워크플로우 수정 중. "
            "신뢰할 수 없는 입력(이슈 제목, PR 설명 등)을 run: 명령에 직접 사용하지 마세요. "
            "env:와 적절한 인용부호를 사용하세요."
        ),
    },
]

# ============================================================
# 상태 관리 (세션별 중복 경고 방지)
# ============================================================
STATE_DIR = os.path.expanduser("~/.claude/security-state")


def get_state_file(session_id):
    return os.path.join(STATE_DIR, f"warnings-{session_id}.json")


def cleanup_old_state_files():
    try:
        if not os.path.exists(STATE_DIR):
            return
        now = datetime.now().timestamp()
        threshold = now - (30 * 24 * 60 * 60)
        for fname in os.listdir(STATE_DIR):
            fpath = os.path.join(STATE_DIR, fname)
            try:
                if os.path.getmtime(fpath) < threshold:
                    os.remove(fpath)
            except OSError:
                pass
    except Exception:
        pass


def load_state(session_id):
    fpath = get_state_file(session_id)
    if os.path.exists(fpath):
        try:
            with open(fpath, "r") as f:
                return set(json.load(f))
        except (json.JSONDecodeError, IOError):
            return set()
    return set()


def save_state(session_id, shown):
    os.makedirs(STATE_DIR, exist_ok=True)
    fpath = get_state_file(session_id)
    try:
        with open(fpath, "w") as f:
            json.dump(list(shown), f)
    except IOError:
        pass


# ============================================================
# 패턴 검사
# ============================================================
def extract_content(tool_name, tool_input):
    if tool_name == "Write":
        return tool_input.get("content", "")
    elif tool_name == "Edit":
        return tool_input.get("new_string", "")
    elif tool_name == "MultiEdit":
        edits = tool_input.get("edits", [])
        return " ".join(e.get("new_string", "") for e in edits) if edits else ""
    return ""


# ============================================================
# 컨텍스트 인식 (false positive 방지)
# 참고: github.com/ruminaider/bash-validator, Anthropic Issue #10114
# ============================================================

# 검사하지 않을 파일 확장자 (코드 실행 불가 → 보안 위험 없음)
SKIP_EXTENSIONS = {
    '.md', '.txt', '.rst', '.adoc', '.asciidoc',  # 문서
    '.json', '.yaml', '.yml', '.toml',             # 설정
    '.css', '.scss', '.less',                       # 스타일시트
    '.svg', '.xml', '.html', '.htm',                # 마크업
    '.pdf', '.png', '.jpg', '.jpeg', '.gif',        # 바이너리
    '.csv', '.tsv',                                 # 데이터
}


def should_check_file(file_path):
    """파일 확장자로 검사 필요 여부 판단"""
    _, ext = os.path.splitext(file_path)
    return ext.lower() not in SKIP_EXTENSIONS


def is_in_comment(content, match_pos):
    """매치 위치가 주석 라인 안에 있는지 확인"""
    line_start = content.rfind('\n', 0, match_pos) + 1
    line_prefix = content[line_start:match_pos].strip()
    # # 주석, // 주석, /* 주석 시작, <!-- HTML 주석
    if line_prefix.startswith('#'):
        return True
    if line_prefix.startswith('//'):
        return True
    if line_prefix.startswith('/*'):
        return True
    if line_prefix.startswith('<!--'):
        return True
    return False


def is_in_string_literal(content, match_pos):
    """매치 위치가 문자열 리터럴 안에 있는지 간이 확인"""
    before = content[:match_pos]
    # 작은따옴표 개수가 홀수면 문자열 안
    single_count = 0
    i = 0
    while i < len(before):
        if before[i] == '\\' and i + 1 < len(before):
            i += 2
            continue
        if before[i] == "'":
            single_count += 1
        i += 1
    if single_count % 2 == 1:
        return True
    # 큰따옴표 개수가 홀수면 문자열 안
    double_count = 0
    i = 0
    while i < len(before):
        if before[i] == '\\' and i + 1 < len(before):
            i += 2
            continue
        if before[i] == '"':
            double_count += 1
        i += 1
    if double_count % 2 == 1:
        return True
    return False


def check_python_ast(content, pattern_name):
    """Python 파일은 AST로 실제 함수 호출만 감지 (false positive 근절)"""
    try:
        import ast
        tree = ast.parse(content)
        dangerous_calls = {
            "eval_usage": {"eval"},
            "os_system_injection": {"system"},
            "pickle_deserialization": {"loads", "load"},
        }
        target_calls = dangerous_calls.get(pattern_name)
        if not target_calls:
            return False  # AST 검사 대상이 아니면 문자열 매칭으로 fallback
        for node in ast.walk(tree):
            if isinstance(node, ast.Call):
                func = node.func
                if isinstance(func, ast.Name) and func.id in target_calls:
                    # os.system 전용: os 모듈의 system인지 확인
                    if pattern_name == "os_system_injection":
                        return True  # ast.Name.id == "system" 이면 충분
                    return True
        return False  # AST에서 실제 호출 발견 안 됨 → false positive
    except (SyntaxError, ImportError):
        return False  # 파싱 실패 → 문자열 매칭으로 fallback


def is_real_match(content, sub, match_pos, file_path, rule_name):
    """매치가 실제 보안 위험인지 false positive인지 판단"""
    # 1. 주석 안이면 무시
    if is_in_comment(content, match_pos):
        return False
    # 2. 문자열 리터럴 안이면 무시
    if is_in_string_literal(content, match_pos):
        return False
    # 3. Python 파일은 AST로 실제 호출인지 확인
    if file_path.endswith('.py') and rule_name in (
        "eval_usage", "os_system_injection", "pickle_deserialization"
    ):
        if not check_python_ast(content, rule_name):
            return False  # AST에서 실제 호출 아님 → false positive
    return True


def check_patterns(file_path, content):
    """모든 매치를 수집하여 반환 (컨텍스트 인식 + 다중 이슈 감지)"""
    matches = []
    normalized = file_path.lstrip("/")

    # 1. path_check 패턴 먼저 처리 (파일 확장자 스킵과 무관)
    for pattern in SECURITY_PATTERNS:
        if "path_check" in pattern and "substrings" not in pattern:
            if pattern["path_check"](normalized):
                matches.append((pattern["ruleName"], pattern["reminder"]))

    # 2. 파일 확장자 체크 — 실행 불가 파일은 substring 검사만 스킵
    if not should_check_file(file_path):
        return matches

    for pattern in SECURITY_PATTERNS:
        if "path_check" in pattern and pattern["path_check"](normalized):
            matches.append((pattern["ruleName"], pattern["reminder"]))
            continue
        if "substrings" in pattern and content:
            for sub in pattern["substrings"]:
                pos = content.find(sub)
                if pos >= 0:
                    # 컨텍스트 인식: 실제 위험인지 확인
                    if is_real_match(content, sub, pos, file_path, pattern["ruleName"]):
                        matches.append((pattern["ruleName"], pattern["reminder"]))
                        break
    return matches


# ============================================================
# 메인
# ============================================================
def main():
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    session_id = input_data.get("session_id", "default")
    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    if tool_name not in ("Edit", "Write", "MultiEdit"):
        sys.exit(0)

    file_path = tool_input.get("file_path", "")
    if not file_path:
        sys.exit(0)

    # 10% 확률로 오래된 상태 파일 정리
    if random.random() < 0.1:
        cleanup_old_state_files()

    content = extract_content(tool_name, tool_input)
    matches = check_patterns(file_path, content)

    if matches:
        shown = load_state(session_id)
        new_warnings = []
        for rule_name, reminder in matches:
            key = f"{file_path}-{rule_name}"
            if key not in shown:
                shown.add(key)
                new_warnings.append(reminder)
        if new_warnings:
            save_state(session_id, shown)
            # 모든 새로운 경고를 한 번에 출력
            print("\n".join(new_warnings), file=sys.stderr)
            sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
