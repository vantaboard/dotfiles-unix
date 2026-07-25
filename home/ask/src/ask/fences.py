"""Split Markdown answers on code fences and print snippets (via bat)."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from typing import Literal, TextIO


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


@dataclass(frozen=True)
class AnswerSegment:
    """One prose or code slice of an assistant answer, in order."""

    kind: Literal["prose", "code"]
    text: str
    language: str = ""


def _normalize_fence_code(code: str) -> str:
    """Strip trailing spaces per line; keep a single final newline."""
    code = code.replace("\r\n", "\n").replace("\r", "\n")
    lines = [line.rstrip(" \t") for line in code.split("\n")]
    while lines and lines[-1] == "":
        lines.pop()
    return "\n".join(lines) + "\n"


def split_answer_segments(text: str) -> list[AnswerSegment]:
    """Split Markdown into ordered prose / code segments at fenced blocks."""
    text = text or ""
    if not text.strip():
        return []
    segments: list[AnswerSegment] = []
    pos = 0
    for match in _FENCE_RE.finditer(text):
        if match.start() > pos:
            prose = text[pos : match.start()].strip()
            if prose:
                segments.append(AnswerSegment("prose", prose + "\n"))
        info = (match.group(1) or "").strip()
        lang = info.split()[0] if info else ""
        code = _normalize_fence_code(match.group(2))
        if code.strip():
            segments.append(AnswerSegment("code", code, language=lang))
        pos = match.end()
    if pos < len(text):
        prose = text[pos:].strip()
        if prose:
            segments.append(AnswerSegment("prose", prose + "\n"))
    if not segments and text.strip():
        segments.append(AnswerSegment("prose", text.strip() + "\n"))
    return segments


def extract_code_fences(text: str) -> list[CodeFence]:
    """Return fenced blocks from Markdown (language may be empty)."""
    return [
        CodeFence(language=seg.language, code=seg.text)
        for seg in split_answer_segments(text)
        if seg.kind == "code"
    ]


def _bat_binary() -> str | None:
    for name in ("bat", "batcat"):
        if shutil.which(name):
            return name
    return None


def print_code_segment(
    code: str,
    *,
    language: str = "",
    file: TextIO[str] | None = None,
    leading_blank: bool = True,
) -> None:
    """Write one code block to the terminal, highlighted with bat when available."""
    out = sys.stdout if file is None else file
    if leading_blank:
        out.write("\n")
        out.flush()

    lang = (language or "bash").strip() or "bash"
    bat = _bat_binary()
    use_bat = (
        bat is not None
        and out is sys.stdout
        and hasattr(out, "isatty")
        and out.isatty()
    )
    if use_bat:
        # --style=plain: no line numbers / grid; --paging=never: don't take over TTY.
        # --color=always: force ANSI highlighting on the TTY.
        cmd = [
            bat,  # type: ignore[list-item]
            "--style=plain",
            "--paging=never",
            "--color=always",
            f"--language={lang}",
        ]
        try:
            proc = subprocess.run(
                cmd,
                input=code.encode("utf-8"),
                check=False,
                stdout=out.buffer if hasattr(out, "buffer") else None,
            )
            if proc.returncode == 0:
                return
        except OSError:
            pass

    out.write(code)
    if not code.endswith("\n"):
        out.write("\n")
    out.flush()


__all__ = [
    "AnswerSegment",
    "CodeFence",
    "extract_code_fences",
    "print_code_segment",
    "split_answer_segments",
]
