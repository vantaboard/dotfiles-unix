"""DuckDuckGo HTML web search for llm-functions / aichat (no API key)."""

from __future__ import annotations

import re
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from typing import Optional

MAX_OUTPUT = 12_288


def _truncate(text: str, limit: int = MAX_OUTPUT) -> str:
    text = text or ""
    if len(text) <= limit:
        return text
    return text[: limit - 20] + "\n...[truncated]"


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


def run(query: str, max_results: Optional[int] = None):
    """Perform a web search via DuckDuckGo HTML (no API key).
    Use this when you need current information or feel a search could provide a better answer.
    Args:
        query: The query to search for.
        max_results: Maximum number of results to return (default 5).
    """
    query = (query or "").strip()
    if not query:
        return "error: empty query"
    limit = 5
    if max_results is not None:
        try:
            limit = max(1, min(int(max_results), 10))
        except (TypeError, ValueError):
            limit = 5

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

    hits = parser.results[:limit]
    if not hits:
        titles = re.findall(
            r'class="result__a"[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
            html,
            flags=re.I | re.S,
        )
        for href, title in titles[:limit]:
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
