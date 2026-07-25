"""Copy answer code fences to the system clipboard."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from dataclasses import dataclass


_FENCE_RE = re.compile(
    r"```([^\n`]*)\n(.*?)```",
    re.DOTALL,
)


@dataclass(frozen=True)
class CodeFence:
    language: str
    code: str

    @property
    def line_count(self) -> int:
        text = self.code.rstrip("\n")
        if not text:
            return 0
        return text.count("\n") + 1


def _normalize_fence_code(code: str) -> str:
    """Strip trailing spaces per line; keep a single final newline."""
    code = code.replace("\r\n", "\n").replace("\r", "\n")
    lines = [line.rstrip(" \t") for line in code.split("\n")]
    # Drop a single trailing empty line from the split, then re-add one newline.
    while lines and lines[-1] == "":
        lines.pop()
    return "\n".join(lines) + "\n"


def extract_code_fences(text: str) -> list[CodeFence]:
    """Return fenced blocks from Markdown (language may be empty)."""
    fences: list[CodeFence] = []
    for match in _FENCE_RE.finditer(text or ""):
        info = (match.group(1) or "").strip()
        lang = info.split()[0] if info else ""
        code = _normalize_fence_code(match.group(2))
        if code.strip():
            fences.append(CodeFence(language=lang, code=code))
    return fences


def pick_primary_fence(fences: list[CodeFence]) -> CodeFence | None:
    """Prefer the largest fence (usually the program), else the last one."""
    if not fences:
        return None
    return max(fences, key=lambda f: (len(f.code), fences.index(f)))


def _run_copy(cmd: list[str], data: bytes) -> bool:
    try:
        subprocess.run(
            cmd,
            input=data,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except (OSError, subprocess.CalledProcessError):
        return False


def copy_text(text: str) -> str | None:
    """Copy ``text`` to clipboard and primary selection when possible.

    Returns the primary tool name used, or None if nothing worked.
    """
    if not text:
        return None
    data = text.encode("utf-8")
    used: str | None = None

    if shutil.which("wl-copy"):
        # CLIPBOARD (Ctrl+V / "+p) and PRIMARY (middle-click / "*p).
        ok_clip = _run_copy(["wl-copy", "--type", "text/plain"], data)
        ok_pri = _run_copy(
            ["wl-copy", "--primary", "--type", "text/plain"], data
        )
        if ok_clip or ok_pri:
            return "wl-copy"

    if shutil.which("xclip"):
        ok_clip = _run_copy(["xclip", "-selection", "clipboard"], data)
        ok_pri = _run_copy(["xclip", "-selection", "primary"], data)
        if ok_clip or ok_pri:
            return "xclip"

    if shutil.which("xsel"):
        ok_clip = _run_copy(["xsel", "--clipboard", "--input"], data)
        ok_pri = _run_copy(["xsel", "--primary", "--input"], data)
        if ok_clip or ok_pri:
            return "xsel"

    if shutil.which("pbcopy") and _run_copy(["pbcopy"], data):
        return "pbcopy"

    return used


def copy_primary_fence(answer: str) -> CodeFence | None:
    """Copy the primary code fence from ``answer``. Returns the fence if copied."""
    fence = pick_primary_fence(extract_code_fences(answer))
    if fence is None:
        return None
    if copy_text(fence.code) is None:
        return None
    return fence


def report_copied(fence: CodeFence) -> None:
    lang = fence.language or "code"
    n = fence.line_count
    unit = "line" if n == 1 else "lines"
    print(f"Copied {lang} ({n} {unit})", file=sys.stderr)


__all__ = [
    "CodeFence",
    "copy_primary_fence",
    "copy_text",
    "extract_code_fences",
    "pick_primary_fence",
    "report_copied",
]
