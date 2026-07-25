"""Human-readable labels for tool invocations (TUI + plain verbose)."""

from __future__ import annotations

from typing import Any


def _arg(args: dict[str, Any], *keys: str, default: str = "") -> str:
    for key in keys:
        val = args.get(key)
        if val is not None and str(val).strip():
            return str(val).strip()
    return default


def running_label(name: str, args: dict[str, Any]) -> str:
    """Present-progressive label while a tool is in flight."""
    del args  # reserved for future per-tool nuance
    if name == "locate_binary":
        return "Locating binary"
    if name == "man_page":
        return "Reading man page"
    if name == "command_help":
        return "Getting command help"
    if name == "web_search":
        return "Searching the web"
    return f"Running {name}"


def done_label(name: str, args: dict[str, Any], *, ok: bool = True) -> str:
    """Past-tense completion line with backtick accents on the subject."""
    if not ok:
        return failed_label(name, args)

    if name == "locate_binary":
        target = _arg(args, "name", default="binary")
        return f"Located `{target}`"
    if name == "man_page":
        page = _arg(args, "page", default="page")
        return f"Read man `{page}`"
    if name == "command_help":
        cmd = _arg(args, "name", default="command")
        flag = _arg(args, "flag", default="--help")
        return f"Ran `{cmd} {flag}`"
    if name == "web_search":
        query = _arg(args, "query", default="query")
        short = query if len(query) <= 48 else query[:45] + "..."
        return f"Searched `{short}`"
    return f"Finished `{name}`"


def failed_label(name: str, args: dict[str, Any]) -> str:
    if name == "locate_binary":
        target = _arg(args, "name", default="binary")
        return f"Could not locate `{target}`"
    if name == "man_page":
        page = _arg(args, "page", default="page")
        return f"No man page for `{page}`"
    if name == "command_help":
        cmd = _arg(args, "name", default="command")
        flag = _arg(args, "flag", default="--help")
        return f"Failed `{cmd} {flag}`"
    if name == "web_search":
        return "Web search failed"
    return f"Failed `{name}`"


def running_markup(frame: str, name: str, args: dict[str, Any]) -> str:
    label = running_label(name, args)
    return f"[magenta]{frame}[/] [dim]{label}[/]"


def done_markup(name: str, args: dict[str, Any], *, ok: bool) -> str:
    """Rich markup for a completed tool line."""
    label = done_label(name, args, ok=ok)
    color = "green" if ok else "red"
    parts = label.split("`")
    out: list[str] = []
    for i, part in enumerate(parts):
        if i % 2 == 1:
            out.append(f"[bold cyan]{part}[/]")
        elif part:
            out.append(f"[{color}]{part}[/]")
    return "".join(out)
