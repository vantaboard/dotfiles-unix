"""Locate a command on PATH for llm-functions / aichat (no arbitrary shell)."""

from __future__ import annotations

import os
import shutil
import subprocess

MAX_OUTPUT = 12_288
TOOL_TIMEOUT_S = 15


def _truncate(text: str, limit: int = MAX_OUTPUT) -> str:
    text = text or ""
    if len(text) <= limit:
        return text
    return text[: limit - 20] + "\n...[truncated]"


def _run(argv: list[str], *, timeout: float = TOOL_TIMEOUT_S) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            argv,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except FileNotFoundError as exc:
        return 127, f"not found: {exc}"
    except subprocess.TimeoutExpired:
        return 124, f"timeout after {timeout}s: {' '.join(argv)}"
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    return proc.returncode, _truncate(out.strip())


def run(name: str):
    """Locate a command on PATH using command -v and type -a.
    Use this before consulting man or --help when answering questions about local CLIs.
    Args:
        name: Simple command basename to locate (no paths or flags).
    """
    name = (name or "").strip()
    if not name or "/" in name or name.startswith("-"):
        return "error: command name must be a simple basename"
    which = shutil.which(name)
    lines: list[str] = []
    if which:
        lines.append(f"command -v: {which}")
        try:
            st = os.stat(which)
            lines.append(f"ls: {oct(st.st_mode & 0o777)} {which}")
        except OSError as exc:
            lines.append(f"stat failed: {exc}")
    else:
        lines.append(f"command -v: not found ({name})")
    code, type_out = _run(["bash", "-lc", 'type -a "$1"', "_", name])
    if type_out:
        lines.append(f"type -a (exit {code}):\n{type_out}")
    return "\n".join(lines)
