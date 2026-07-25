"""Allowlisted tools for the ask agent (no arbitrary shell)."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from typing import Any, Callable

MAX_OUTPUT = 12_288
TOOL_TIMEOUT_S = 15


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


def locate_binary(name: str) -> str:
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
    # Quote-safe: pass name as $1 to bash -lc.
    code, type_out = _run(["bash", "-lc", 'type -a "$1"', "_", name])
    if type_out:
        lines.append(f"type -a (exit {code}):\n{type_out}")
    return "\n".join(lines)


def man_page(page: str) -> str:
    page = (page or "").strip()
    if not page or "/" in page or page.startswith("-"):
        return "error: page must be a simple man page name"
    env = os.environ.copy()
    env["MANWIDTH"] = "80"
    env["MANPAGER"] = "cat"
    code, out = _run(["man", "-P", "cat", page], env=env, timeout=20)
    if code != 0 and not out:
        return f"man failed (exit {code}) for {page}"
    return out or f"(empty man page for {page}, exit {code})"


def command_help(name: str, flag: str = "--help") -> str:
    name = (name or "").strip()
    flag = (flag or "--help").strip()
    if not name or "/" in name or name.startswith("-"):
        return "error: command must be a simple basename"
    if flag not in ("--help", "-h", "-help"):
        return "error: flag must be --help, -h, or -help"
    resolved = shutil.which(name)
    if not resolved:
        return f"error: {name!r} not found on PATH"
    # Resolve to real path; reject if somehow not a file we can exec.
    if not os.path.isfile(resolved):
        return f"error: {resolved} is not a regular file"
    code, out = _run([resolved, flag], timeout=TOOL_TIMEOUT_S)
    header = f"{resolved} {flag} (exit {code})"
    return f"{header}\n{out}" if out else header


class _DDGParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.results: list[dict[str, str]] = []
        self._in_result = False
        self._in_title = False
        self._in_snippet = False
        self._current: dict[str, str] | None = None
        self._buf: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        ad = {k: (v or "") for k, v in attrs}
        classes = set(ad.get("class", "").split())
        if tag == "div" and "result" in classes and (
            "results_links" in classes or "web-result" in classes
        ):
            self._in_result = True
            self._current = {"title": "", "url": "", "snippet": ""}
        elif self._in_result and tag == "a" and "result__a" in classes:
            self._in_title = True
            self._buf = []
            href = ad.get("href", "")
            if self._current is not None:
                parsed = urllib.parse.urlparse(href)
                qs = urllib.parse.parse_qs(parsed.query)
                if "uddg" in qs:
                    self._current["url"] = qs["uddg"][0]
                else:
                    self._current["url"] = href
        elif self._in_result and "result__snippet" in classes:
            self._in_snippet = True
            self._buf = []

    def handle_endtag(self, tag: str) -> None:
        if self._in_title and tag == "a":
            if self._current is not None:
                self._current["title"] = re.sub(
                    r"\s+", " ", "".join(self._buf)
                ).strip()
            self._in_title = False
            self._buf = []
        elif self._in_snippet and tag in ("a", "td", "div"):
            if self._current is not None and not self._current.get("snippet"):
                self._current["snippet"] = re.sub(
                    r"\s+", " ", "".join(self._buf)
                ).strip()
            self._in_snippet = False
            self._buf = []
        elif tag == "div" and self._in_result and self._current is not None:
            if self._current.get("title") or self._current.get("url"):
                self.results.append(self._current)
            self._current = None
            self._in_result = False

    def handle_data(self, data: str) -> None:
        if self._in_title or self._in_snippet:
            self._buf.append(data)


def web_search(query: str, *, max_results: int = 5) -> str:
    query = (query or "").strip()
    if not query:
        return "error: empty query"
    # POST avoids DuckDuckGo's bot interstitial that GET often returns.
    body = urllib.parse.urlencode({"q": query, "b": ""}).encode("utf-8")
    req = urllib.request.Request(
        "https://html.duckduckgo.com/html/",
        data=body,
        headers={
            "User-Agent": (
                "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            ),
            "Accept": "text/html,application/xhtml+xml",
            "Content-Type": "application/x-www-form-urlencoded",
            "Referer": "https://html.duckduckgo.com/",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            html = resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as exc:
        return f"error: DuckDuckGo HTTP {exc.code}"
    except urllib.error.URLError as exc:
        return f"error: DuckDuckGo request failed: {exc.reason}"
    parser = _DDGParser()
    try:
        parser.feed(html)
    except Exception as exc:  # noqa: BLE001 — keep tool resilient
        return f"error: failed to parse DuckDuckGo HTML: {exc}"
    hits = parser.results[:max_results]
    if not hits:
        # Fallback: crude link scrape if markup changes.
        titles = re.findall(
            r'class="result__a"[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
            html,
            flags=re.I | re.S,
        )
        for href, title in titles[:max_results]:
            clean = re.sub(r"<[^>]+>", "", title)
            parsed = urllib.parse.urlparse(href)
            qs = urllib.parse.parse_qs(parsed.query)
            real = qs.get("uddg", [href])[0]
            hits.append(
                {
                    "title": re.sub(r"\s+", " ", clean).strip(),
                    "url": real,
                    "snippet": "",
                }
            )
    if not hits:
        return "no results"
    lines = []
    for i, hit in enumerate(hits, 1):
        lines.append(f"{i}. {hit.get('title') or '(no title)'}")
        if hit.get("url"):
            lines.append(f"   {hit['url']}")
        if hit.get("snippet"):
            lines.append(f"   {hit['snippet']}")
    return _truncate("\n".join(lines))


ToolFn = Callable[..., str]

TOOL_IMPLS: dict[str, ToolFn] = {
    "locate_binary": locate_binary,
    "man_page": man_page,
    "command_help": command_help,
    "web_search": web_search,
}


def openai_tool_schemas(*, include_web: bool) -> list[dict[str, Any]]:
    tools: list[dict[str, Any]] = [
        {
            "type": "function",
            "function": {
                "name": "locate_binary",
                "description": (
                    "Locate a command on PATH using command -v and type -a. "
                    "Use this before consulting man or --help."
                ),
                "parameters": {
                    "type": "object",
                    "properties": {
                        "name": {
                            "type": "string",
                            "description": "Command basename, e.g. trash-restore",
                        }
                    },
                    "required": ["name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "man_page",
                "description": "Read a man page as plain text.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "page": {
                            "type": "string",
                            "description": "Man page name, e.g. trash-restore",
                        }
                    },
                    "required": ["page"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "command_help",
                "description": (
                    "Run an allowlisted command with --help or -h after "
                    "resolving it on PATH."
                ),
                "parameters": {
                    "type": "object",
                    "properties": {
                        "name": {
                            "type": "string",
                            "description": "Command basename",
                        },
                        "flag": {
                            "type": "string",
                            "description": "--help (default), -h, or -help",
                            "enum": ["--help", "-h", "-help"],
                        },
                    },
                    "required": ["name"],
                },
            },
        },
    ]
    if include_web:
        tools.append(
            {
                "type": "function",
                "function": {
                    "name": "web_search",
                    "description": (
                        "Search the web via DuckDuckGo HTML. Use to identify "
                        "named products/tools, and when local man/--help is "
                        "missing, incomplete, or unclear."
                    ),
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "query": {
                                "type": "string",
                                "description": "Search query",
                            }
                        },
                        "required": ["query"],
                    },
                },
            }
        )
    return tools


def run_tool(name: str, arguments: dict[str, Any] | str) -> tuple[bool, str]:
    if isinstance(arguments, str):
        try:
            arguments = json.loads(arguments) if arguments.strip() else {}
        except json.JSONDecodeError:
            return False, f"error: invalid JSON arguments: {arguments!r}"
    if not isinstance(arguments, dict):
        return False, "error: arguments must be an object"
    fn = TOOL_IMPLS.get(name)
    if fn is None:
        return False, f"error: unknown tool {name!r}"
    try:
        if name == "locate_binary":
            result = fn(str(arguments.get("name", "")))
        elif name == "man_page":
            result = fn(str(arguments.get("page", "")))
        elif name == "command_help":
            result = fn(
                str(arguments.get("name", "")),
                str(arguments.get("flag", "--help")),
            )
        elif name == "web_search":
            result = fn(str(arguments.get("query", "")))
        else:
            return False, f"error: unhandled tool {name!r}"
    except Exception as exc:  # noqa: BLE001
        return False, f"error: {exc}"
    ok = not result.startswith("error:")
    return ok, result


SYSTEM_PROMPT = """\
You are a concise terminal assistant on the user's machine. You answer \
questions about software, CLI tools, and how to get things done in a shell.

Rules:
- Prefer tools over guessing. For local binaries: locate first, then man \
and --help. Do not invent flags; quote what tools return.
- Use web_search for named products, apps, or services the user mentions \
(e.g. "Cursor", "vscode", "docker desktop") and whenever local docs are \
missing or unclear. Prefer search over asking the user what a well-known \
tool is.
- Be concise and actionable; show exact commands when relevant.
- Ask at most one short clarifying question, and only when you truly cannot \
proceed (missing a required fact with no reasonable default). End that \
question with ? and stop.
- After the user replies, do not ask another clarifying question about the \
same topic — use tools (especially web_search) and answer.
- After gathering evidence, give a clear final answer in Markdown.
- Put shell commands in fenced code blocks with a language tag, e.g. ```bash \
or ```sh. Use ```python for Python. Never leave fences unlabeled.
"""
