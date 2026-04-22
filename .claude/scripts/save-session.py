#!/usr/bin/env python3
"""세션 상태 자동 저장 — on-session-end.sh에서 호출"""
import sys, json, os, subprocess
from datetime import datetime

def save_session(project_dir, sessions_dir, session_id, log_file):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Parse audit log for this session
    agents_used = []
    agent_times = {}
    if os.path.exists(log_file):
        with open(log_file) as f:
            for line in f:
                if f"session={session_id}" not in line:
                    continue
                time_str = ""
                if line.startswith("["):
                    time_str = line[1 : line.index("]")]
                if "subagent=" in line:
                    parts = line.split("subagent=")
                    if len(parts) > 1:
                        agent = parts[1].split()[0].strip()
                        if agent not in agents_used:
                            agents_used.append(agent)
                            agent_times[agent] = time_str

    # Workflow phase mapping
    phase_map = {
        "code-explorer": "Phase B (탐색)",
        "code-architect": "Phase B (설계)",
        "code-writer": "Phase F (구현)",
        "spec-reviewer": "Phase G (스펙 리뷰)",
        "quality-reviewer": "Phase G (품질 리뷰)",
        "test-architect": "Phase D (테스트 설계)",
        "code-integrator": "통합",
    }

    completed_phases = []
    for agent in agents_used:
        if agent in phase_map:
            completed_phases.append(
                (phase_map[agent], agent, agent_times.get(agent, ""))
            )

    # Determine current workflow phase
    if not agents_used:
        current_phase = "Phase A (대화/PRD)"
    elif "code-integrator" in agents_used:
        current_phase = "Phase G (통합 완료)"
    elif "quality-reviewer" in agents_used:
        current_phase = "Phase G (품질 리뷰 완료)"
    elif "spec-reviewer" in agents_used:
        current_phase = "Phase G (스펙 리뷰 완료)"
    elif "code-writer" in agents_used:
        current_phase = "Phase F/G (구현 완료, 리뷰 대기)"
    elif "code-architect" in agents_used:
        current_phase = "Phase C-F (설계 완료, 구현 대기)"
    elif "code-explorer" in agents_used:
        current_phase = "Phase B (탐색 완료, 설계 대기)"
    else:
        current_phase = "Phase A (대화/PRD)"

    # Find PRD files
    prd_files = []
    if os.path.isdir(project_dir):
        for f in os.listdir(project_dir):
            if f.startswith("PRD") and f.endswith(".md"):
                prd_files.append(f)

    # Git status
    git_status = ""
    try:
        result = subprocess.run(
            ["git", "status", "--short"],
            capture_output=True,
            text=True,
            cwd=project_dir,
            timeout=5,
        )
        git_status = result.stdout.strip()
    except Exception:
        git_status = "(확인 불가)"

    # Git branch
    git_branch = ""
    try:
        result = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True,
            text=True,
            cwd=project_dir,
            timeout=5,
        )
        git_branch = result.stdout.strip()
    except Exception:
        git_branch = "(확인 불가)"

    # Build latest.md
    lines = [
        "# 세션 상태 (자동 저장)",
        "",
        f"- **프로젝트**: {project_dir}",
        f"- **브랜치**: {git_branch}",
        f"- **세션 ID**: {session_id}",
        f"- **저장 시간**: {ts}",
        f"- **현재 단계**: {current_phase}",
        "",
        "## 완료된 에이전트 작업",
    ]
    for phase_name, agent_name, time in completed_phases:
        lines.append(f"- {phase_name} \u2014 {agent_name} ({time})")
    if not completed_phases:
        lines.append("- (에이전트 작업 없음)")

    lines.extend(
        [
            "",
            "## 파일 변경",
            "```",
            git_status or "(변경 사항 없음)",
            "```",
            "",
            "## PRD 파일",
        ]
    )
    for prd in sorted(prd_files):
        lines.append(f"- {prd}")
    if not prd_files:
        lines.append("- (PRD 없음)")

    lines.append("")

    # Write latest.md
    os.makedirs(sessions_dir, exist_ok=True)
    with open(os.path.join(sessions_dir, "latest.md"), "w") as f:
        f.write("\n".join(lines))

    print("SESSION_SAVED")


if __name__ == "__main__":
    project_dir = sys.argv[1]
    sessions_dir = sys.argv[2]
    session_id = sys.argv[3]
    log_file = sys.argv[4]
    save_session(project_dir, sessions_dir, session_id, log_file)
