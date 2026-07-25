"""Markdown helpers for syntax-highlighted code fences."""

from __future__ import annotations


def tag_code_fences(text: str, *, default_language: str = "bash") -> str:
    """Ensure fenced code blocks have a language tag for highlighters.

    Unlabeled opening fences (``` alone) become ```bash (or ``default_language``).
    Closing fences and already-tagged fences are left alone.
    """
    if not text:
        return text
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    in_fence = False
    for line in lines:
        stripped = line.lstrip()
        if stripped.startswith("```"):
            # Preserve indentation before the fence.
            indent = line[: len(line) - len(stripped)]
            info = stripped.strip()[3:].strip()
            newline = "\n" if line.endswith("\n") else ""
            if not in_fence:
                in_fence = True
                if not info:
                    out.append(f"{indent}```{default_language}{newline}")
                    continue
            else:
                in_fence = False
        out.append(line)
    return "".join(out)


def print_rich_markdown(text: str) -> None:
    """Print Markdown to stdout with Rich syntax highlighting."""
    from rich.console import Console
    from rich.markdown import Markdown

    console = Console(highlight=True)
    console.print(Markdown(tag_code_fences(text), code_theme="monokai"))
