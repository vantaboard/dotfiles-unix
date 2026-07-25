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


def extract_code_fences(text: str) -> list[CodeFence]:
    """Return fenced blocks from Markdown (language may be empty)."""
    fences: list[CodeFence] = []
    for match in _FENCE_RE.finditer(text or ""):
        lang = (match.group(1) or "").strip().split()[0] if match.group(1) else ""
        code = match.group(2)
        # Normalize to a single trailing newline for clean pastes.
        code = code.replace("\r\n", "\n").replace("\r", "\n")
        if not code.endswith("\n"):
            code += "\n"
        if code.strip():
            fences.append(CodeFence(language=lang, code=code))
    return fences


def pick_primary_fence(fences: list[CodeFence]) -> CodeFence | None:
    """Prefer the largest fence (usually the program), else the last one."""
    if not fences:
        return None
    return max(fences, key=lambda f: (len(f.code), fences.index(f)))


def copy_text(text: str) -> str | None:
    """Copy ``text`` to the clipboard. Returns the tool used, or None."""
    if not text:
        return None
    candidates: list[list[str]] = []
    if shutil.which("wl-copy"):
        candidates.append(["wl-copy", "--type", "text/plain"])
    if shutil.which("xclip"):
        candidates.append(["xclip", "-selection", "clipboard"])
    if shutil.which("xsel"):
        candidates.append(["xsel", "--clipboard", "--input"])
    if shutil.which("pbcopy"):
        candidates.append(["pbcopy"])
    data = text.encode("utf-8")
    for cmd in candidates:
        try:
            subprocess.run(
                cmd,
                input=data,
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return cmd[0]
        except (OSError, subprocess.CalledProcessError):
            continue
    return None


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
