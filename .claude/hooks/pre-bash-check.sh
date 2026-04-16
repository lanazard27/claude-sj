#!/bin/bash
# ~/.claude/hooks/pre-bash-check.sh
# PreToolUse hook for Bash — 위험 명령어 실행 전 차단
# stdin: JSON with tool_name, tool_input
# exit 0 = 허용, exit 2 = 차단 (stderr가 Claude에게 전달됨)
#
# v2: heredoc placeholder 치환 + 인용부호 인식 매칭으로 false positive 방지
# 참고: github.com/ruminaider/bash-validator (heredoc stripping 기법)

# Python으로 전체 로직 처리 (heredoc/인용부호 처리가 bash만으로는 한계)
exec python3 -c "
import sys, json, re

def main():
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool_name = input_data.get('tool_name', '')
    if tool_name != 'Bash':
        sys.exit(0)

    command = input_data.get('tool_input', {}).get('command', '')
    if not command:
        sys.exit(0)

    # ============================================================
    # Heredoc 내용 placeholder 치환 (false positive 근절)
    # $(cat <<'DELIM'...DELIM) 형태의 heredoc 내용을 __HEREDOC__ 으로 치환
    # ============================================================
    def strip_heredocs(cmd):
        # <<'DELIM' ... DELIM 패턴 (single-quoted delimiter = 변수 확장 없음)
        result = re.sub(
            r\"\"\"<<-?\s*'([A-Za-z_]\\w*)'\\s*\\n.*?\\n\\s*\\1\"\"\",
            \"<<'HEREDOC_REDACTED'\",
            cmd,
            flags=re.DOTALL
        )
        # <<DELIM ... DELIM 패턴 (unquoted delimiter)
        result = re.sub(
            r\"\"\"<<-?\s*(\\w+)\\s*\\n.*?\\n\\s*\\1\"\"\",
            \"<<HEREDOC_REDACTED\",
            result,
            flags=re.DOTALL
        )
        return result

    # ============================================================
    # 인용부호 인식 매칭 (따옴표 안의 패턴은 무시)
    # ============================================================
    def contains_unquoted(cmd, pattern):
        \"\"\"패턴이 따옴표 밖에 있는지 확인\"\"\"
        i = 0
        while i < len(cmd):
            if cmd[i] == \"'\":
                j = cmd.find(\"'\", i + 1)
                if j == -1:
                    break
                i = j + 1  # 작은따옴표 안 스킵
            elif cmd[i] == '\"':
                j = i + 1
                while j < len(cmd):
                    if cmd[j] == '\\\\' and j + 1 < len(cmd):
                        j += 2
                        continue
                    if cmd[j] == '\"':
                        break
                    j += 1
                i = j + 1  # 큰따옴표 안 스킵
            else:
                if cmd[i:i + len(pattern)] == pattern:
                    return True
                i += 1
        return False

    # heredoc 치환 후 검사
    clean_cmd = strip_heredocs(command)

    # ============================================================
    # 1. 대량 파괴 명령어
    # ============================================================
    destructive = [
        (r'rm\s+-rf\s+/(?:\s|$)', 'rm -rf /'),
        (r'rm\s+-rf\s+~(?:\s|$)', 'rm -rf ~'),
        (r'rm\s+-rf\s+/\*', 'rm -rf /*'),
        (r'chmod\s+777\s+/(?:\s|$)', 'chmod 777 /'),
        (r'chmod\s+-R\s+777\s+/(?:\s|$)', 'chmod -R 777 /'),
        (r'mkfs\.', 'mkfs'),
        (r'>\s*/dev/sd', '> /dev/sd'),
        (r'dd\s+if=.*of=/dev/', 'dd of=/dev/'),
        (r':\(\)\{.*:\|:&.*\}', 'fork bomb'),
    ]
    for pat, display in destructive:
        if re.search(pat, clean_cmd) and contains_unquoted(clean_cmd, display.split()[0] if ' ' in display else display):
            print(f\"BLOCKED: 대량 파괴 명령어 감지 — '{display}' — 시스템 보호를 위해 차단됩니다.\", file=sys.stderr)
            sys.exit(2)

    # ============================================================
    # 2. 원격 스크립트 실행 (curl/wget | shell)
    # ============================================================
    remote_match = re.search(r'(curl|wget)\s+.*\|\s*(bash|sh|zsh|fish)', clean_cmd)
    if remote_match and contains_unquoted(clean_cmd, '|'):
        print('BLOCKED: 원격 스크립트 직접 실행 감지 — 공급망 공격 방지를 위해 차단됩니다.', file=sys.stderr)
        sys.exit(2)

    # ============================================================
    # 3. 시스템 크리티컬 경로 쓰기
    # ============================================================
    sys_write = re.search(r'(>|>>|tee|cp\s|mv\s|install\s).*(/etc/|/sys/|/proc/|/boot/)', clean_cmd)
    if sys_write:
        print('BLOCKED: 시스템 크리티컬 경로 쓰기 감지 — 시스템 무결성 보호를 위해 차단됩니다.', file=sys.stderr)
        sys.exit(2)

    # ============================================================
    # 4. SSH 키 삭제
    # ============================================================
    ssh_del = re.search(r'rm\s+.*(id_rsa|id_ed25519|id_ecdsa|\.pem|\.key)', clean_cmd)
    if ssh_del:
        print('BLOCKED: SSH 키/인증서 삭제 감지 — 보안 인증서 보호를 위해 차단됩니다.', file=sys.stderr)
        sys.exit(2)

    sys.exit(0)

main()
"
