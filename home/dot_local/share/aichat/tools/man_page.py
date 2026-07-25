"""Fetch a man page for llm-functions / aichat (no arbitrary shell)."""

from __future__ import annotations

import os
import subprocess

MAX_OUTPUT = 12_288
TOOL_TIMEOUT_S = 20


def _truncate(text: str, limit: int = MAX_OUTPUT) -> str:
    text = text or ""
    if len(text) <= limit:
        return text
    return text[: limit - 20] + "\n...[truncated]"


def _run(
    argv: list[str],
    *,
    env: dict[str, str] | None = None,
    timeout: float = TOOL_TIMEOUT_S,
) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            argv,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
            check=False,
        )
    except FileNotFoundError as exc:
        return 127, f"not found: {exc}"
    except subprocess.TimeoutExpired:
        return 124, f"timeout after {timeout}s: {' '.join(argv)}"
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    return proc.returncode, _truncate(out.strip())


def run(page: str):
    """Read a man page with man -P cat.
    Use when --help is missing or incomplete for a local command.
    Args:
        page: Simple man page name (no paths or section prefixes like ./).
    """
    page = (page or "").strip()
    if not page or "/" in page or page.startswith("-"):
        return "error: page must be a simple man page name"
    env = os.environ.copy()
    env["MANWIDTH"] = "80"
    env["MANPAGER"] = "cat"
    code, out = _run(["man", "-P", "cat", page], env=env, timeout=TOOL_TIMEOUT_S)
    if code != 0 and not out:
        return f"man failed (exit {code}) for {page}"
    return out or f"(empty man page for {page}, exit {code})"
