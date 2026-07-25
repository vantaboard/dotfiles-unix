"""Inline Textual UI: tool cards + adaptive Markdown typewriter stream."""

from __future__ import annotations

import asyncio
import queue
import sys
import time
from typing import Any

from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Vertical
from textual.content import Content
from textual.highlight import (
    ANSIDarkHighlightTheme,
    ANSILightHighlightTheme,
    highlight,
)
from textual.reactive import reactive
from textual.widget import Widget
from textual.widgets import Label, Markdown, Static
from textual.widgets._markdown import MarkdownFence

from ask.agent import AgentCallbacks, AgentConfig, AgentResult, run_agent
from ask.think_anim import think_frame
from ask.tool_labels import done_markup, running_markup
from ask.typewriter import AdaptiveTypewriter


class HighlightedFence(MarkdownFence):
    """Fence block that always uses vivid ANSI token colors."""

    @classmethod
    def highlight(
        cls,
        code: str,
        language: str,
        ansi: bool = False,
        dark: bool = True,
    ) -> Content:
        del ansi  # always prefer true ANSI token colors in the terminal
        theme = ANSIDarkHighlightTheme if dark else ANSILightHighlightTheme
        return highlight(
            code,
            language=language or "bash",
            theme=theme,
        )


class AskMarkdown(Markdown):
    """Markdown widget with ANSI-highlighted code fences."""

    BLOCKS = {
        **Markdown.BLOCKS,
        "fence": HighlightedFence,
        "code_block": HighlightedFence,
    }


_TICK_S = 1.0 / 60.0
_THINK_INTERVAL_S = 0.14

_DELTA = "delta"
_PREAMBLE = "preamble"
_STATUS = "status"
_TOOL_START = "tool_start"
_TOOL_END = "tool_end"
_DONE = "done"


class ToolCard(Widget):
    """Compact status card for one tool invocation."""

    DEFAULT_CSS = """
    ToolCard {
        height: auto;
        padding: 0 1;
    }
    ToolCard > .tool-line {
        height: 1;
    }
    ToolCard > .tool-detail {
        color: $text-muted;
        padding: 0 0 0 2;
        max-height: 4;
    }
    """

    status: reactive[str] = reactive("running")

    def __init__(
        self,
        call_id: str,
        name: str,
        args: dict[str, Any],
        *,
        verbose: bool = False,
    ) -> None:
        super().__init__()
        self.call_id = call_id
        self.tool_name = name
        self.args = args
        self.verbose = verbose
        self._spin_index = 0

    def compose(self) -> ComposeResult:
        yield Label(
            running_markup(think_frame(0), self.tool_name, self.args),
            classes="tool-line",
            id="line",
            markup=True,
        )
        if self.verbose:
            yield Static("", classes="tool-detail", id="detail")

    def on_mount(self) -> None:
        self.set_interval(_THINK_INTERVAL_S, self._tick)

    def _tick(self) -> None:
        if self.status != "running":
            return
        self._spin_index += 1
        self.query_one("#line", Label).update(
            running_markup(
                think_frame(self._spin_index), self.tool_name, self.args
            )
        )

    def finish(self, ok: bool, detail: str) -> None:
        self.status = "success" if ok else "error"
        self.query_one("#line", Label).update(
            done_markup(self.tool_name, self.args, ok=ok)
        )
        if self.verbose:
            preview = detail.replace("\n", " ").strip()
            if len(preview) > 160:
                preview = preview[:157] + "..."
            try:
                self.query_one("#detail", Static).update(preview)
            except Exception:  # noqa: BLE001
                pass


class AskApp(App[str]):
    """Inline app: status + tool cards + streamed Markdown answer."""

    BINDINGS = [
        Binding("ctrl+c", "quit_ask", "Quit", show=False, priority=True),
        Binding("ctrl+q", "quit_ask", "Quit", show=False),
    ]

    CSS = """
    AskApp {
        height: auto;
        max-height: 36;
        background: transparent;
    }
    #status {
        height: 1;
        color: $text-muted;
        padding: 0 1;
    }
    #tools {
        height: auto;
        background: transparent;
    }
    #body {
        height: auto;
        max-height: 28;
        margin: 0 1;
        padding: 0;
        background: transparent;
    }
    MarkdownFence {
        margin: 1 0;
        background: #1e1e1e;
        color: #d4d4d4;
    }
    MarkdownFence > Label {
        padding: 1 2;
    }
    """

    def __init__(
        self,
        question: str,
        config: AgentConfig,
        *,
        verbose: bool = False,
    ) -> None:
        super().__init__()
        self._question = question
        self._config = config
        self._verbose = verbose
        self._result = ""
        self._started = time.monotonic()
        self._events: queue.Queue[tuple[str, Any]] = queue.Queue()
        self._has_text = False
        self._spin_index = 0
        self._typewriter = AdaptiveTypewriter()
        self._cards: dict[str, ToolCard] = {}
        self._status_base = "Thinking..."

    def compose(self) -> ComposeResult:
        yield Label(
            f"[magenta]{think_frame(0)}[/] [dim]{self._status_base}[/]",
            id="status",
            markup=True,
        )
        yield Vertical(id="tools")
        markdown = AskMarkdown(id="body")
        markdown.code_indent_guides = False
        yield markdown

    def on_mount(self) -> None:
        self.set_interval(_THINK_INTERVAL_S, self._tick_spinner)
        self.run_worker(self._run_agent, thread=True)
        self.run_worker(self._drive_ui)

    def action_quit_ask(self) -> None:
        self.exit("")

    def _status_markup(self, frame: str | None = None) -> str:
        glyph = frame if frame is not None else think_frame(self._spin_index)
        return f"[magenta]{glyph}[/] [dim]{self._status_base}[/]"

    def _tick_spinner(self) -> None:
        if self._has_text:
            return
        self._spin_index += 1
        self.query_one("#status", Label).update(
            self._status_markup(think_frame(self._spin_index))
        )

    def _run_agent(self) -> None:
        def on_delta(text: str) -> None:
            if text:
                self._events.put((_DELTA, text))

        def on_preamble(text: str) -> None:
            if text:
                self._events.put((_PREAMBLE, text))

        def on_status(text: str) -> None:
            if text:
                self._events.put((_STATUS, text))

        def on_tool_start(
            call_id: str, name: str, args: dict[str, Any]
        ) -> None:
            self._events.put((_TOOL_START, (call_id, name, args)))

        def on_tool_end(call_id: str, ok: bool, detail: str) -> None:
            self._events.put((_TOOL_END, (call_id, ok, detail)))

        try:
            result: AgentResult = run_agent(
                self._question,
                config=self._config,
                callbacks=AgentCallbacks(
                    on_delta=on_delta,
                    on_preamble=on_preamble,
                    on_status=on_status,
                    on_tool_start=on_tool_start,
                    on_tool_end=on_tool_end,
                ),
            )
            self._result = result.answer or result.error or ""
        except Exception as exc:  # noqa: BLE001
            self._result = f"error: {exc}"
            self._events.put((_STATUS, self._result))
        finally:
            self._events.put((_DONE, self._result))

    async def _drive_ui(self) -> None:
        status = self.query_one("#status", Label)
        tools = self.query_one("#tools", Vertical)
        markdown = self.query_one("#body", AskMarkdown)
        stream = Markdown.get_stream(markdown)
        tw = self._typewriter

        async def ingest() -> None:
            nonlocal stream
            while True:
                kind, payload = await asyncio.to_thread(self._events.get)
                if kind == _STATUS:
                    self._status_base = str(payload)
                    if not self._has_text:
                        status.update(self._status_markup())
                    else:
                        status.update(f"[dim]{payload}[/]")
                elif kind == _PREAMBLE:
                    preview = str(payload).replace("\n", " ").strip()
                    if len(preview) > 100:
                        preview = preview[:97] + "..."
                    self._status_base = f"... {preview}"
                    status.update(self._status_markup())
                elif kind == _DELTA:
                    if not self._has_text:
                        self._has_text = True
                        status.update("[dim]Writing...[/]")
                    tw.extend_target(str(payload))
                elif kind == _TOOL_START:
                    call_id, name, args = payload
                    card = ToolCard(
                        call_id, name, args, verbose=self._verbose
                    )
                    self._cards[call_id] = card
                    await tools.mount(card)
                elif kind == _TOOL_END:
                    call_id, ok, detail = payload
                    card = self._cards.get(call_id)
                    if card is not None:
                        card.finish(ok, detail)
                elif kind == _DONE:
                    # Ensure answer is in the typewriter even if on_delta was skipped.
                    if payload and not tw.target:
                        tw.extend_target(str(payload))
                        self._has_text = True
                    tw.mark_done()
                    return

        async def drip() -> None:
            write = stream.write
            while True:
                slice_text = tw.tick(_TICK_S)
                if slice_text:
                    await write(slice_text)
                if tw.done and tw.caught_up:
                    return
                await asyncio.sleep(_TICK_S)

        try:
            await asyncio.gather(ingest(), drip())
        finally:
            remaining = tw.snap()
            if remaining:
                await stream.write(remaining)
            await stream.stop()
            elapsed = max(1, int(round(time.monotonic() - self._started)))
            status.update(
                f"[dim]Thought for {elapsed}s · {self._config.model}[/]"
            )
            self.exit(self._result)


def prompt_for_question(*, use_textual: bool | None = None) -> str | None:
    """Prompt for a question in normal terminal mode (scroll/selection work).

    Avoids a Textual input app here: mouse capture blocks terminal scrollback
    and drag-to-highlight. ``use_textual`` is accepted for API compatibility
    but ignored.
    """
    del use_textual
    interactive = bool(
        getattr(sys.stdin, "isatty", lambda: False)()
        and getattr(sys.stdout, "isatty", lambda: False)()
    )
    if not interactive:
        return None
    try:
        from ask.history import setup_readline_history

        setup_readline_history()
    except Exception:  # noqa: BLE001 — prompt must still work without history
        pass
    try:
        print("Ask (Enter to submit, Ctrl+C to cancel)", file=sys.stderr)
        return input("ask> ").strip() or None
    except (EOFError, KeyboardInterrupt):
        print(file=sys.stderr)
        return None


def run_ask_tui(
    question: str,
    config: AgentConfig,
    *,
    verbose: bool = False,
    use_textual: bool | None = None,
) -> str:
    """Run ask with Textual when on a TTY; otherwise plain stdout."""
    from ask.agent import run_agent_plain

    interactive = bool(
        getattr(sys.stdout, "isatty", lambda: False)()
        and getattr(sys.stderr, "isatty", lambda: False)()
    )
    textual_ui = interactive if use_textual is None else use_textual
    if not textual_ui:
        result = run_agent_plain(question, config=config, verbose=verbose)
        return result.answer or ""

    app = AskApp(question, config, verbose=verbose)
    try:
        # mouse=False keeps terminal scrollback + drag-select working.
        return app.run(inline=True, inline_no_clear=True, mouse=False) or ""
    except KeyboardInterrupt:
        return ""


__all__ = ["AskApp", "prompt_for_question", "run_ask_tui"]
