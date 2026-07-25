"""Run --help on a PATH binary for llm-functions / aichat (no arbitrary shell)."""

from __future__ import annotations

import os
import shutil
import subprocess
from typing import Literal, Optional

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


def run(name: str, flag: Optional[Literal["--help", "-h", "-help"]] = None):
    """Run a command's help flag (--help by default) and return the output.
    Use after locate_binary when explaining how to use a local CLI.
    Args:
        name: Simple command basename on PATH (no paths).
        flag: Help flag to pass: --help, -h, or -help (default --help).
    """
    name = (name or "").strip()
    flag = (flag or "--help").strip()
    if not name or "/" in name or name.startswith("-"):
        return "error: command must be a simple basename"
    if flag not in ("--help", "-h", "-help"):
        return "error: flag must be --help, -h, or -help"
    resolved = shutil.which(name)
    if not resolved:
        return f"error: {name!r} not found on PATH"
    if not os.path.isfile(resolved):
        return f"error: {resolved} is not a regular file"
    code, out = _run([resolved, flag], timeout=TOOL_TIMEOUT_S)
    header = f"{resolved} {flag} (exit {code})"
    return f"{header}\n{out}" if out else header
