"""OpenAI-compatible tool-calling agent loop against llama-swap."""

from __future__ import annotations

import json
import urllib.error
import urllib.request
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

from ask.tools import SYSTEM_PROMPT, openai_tool_schemas, run_tool

DEFAULT_BASE_URL = "http://127.0.0.1:9292/v1"
DEFAULT_MODEL = "chat"
DEFAULT_MAX_ROUNDS = 6


@dataclass
class AgentCallbacks:
    """UI hooks; all optional and may be called from a worker thread."""

    on_delta: Callable[[str], None] | None = None
    on_preamble: Callable[[str], None] | None = None
    on_status: Callable[[str], None] | None = None
    on_tool_start: Callable[[str, str, dict[str, Any]], None] | None = None
    on_tool_end: Callable[[str, bool, str], None] | None = None


@dataclass
class AgentConfig:
    base_url: str = DEFAULT_BASE_URL
    model: str = DEFAULT_MODEL
    max_rounds: int = DEFAULT_MAX_ROUNDS
    include_web: bool = True
    temperature: float = 0.2
    max_tokens: int = 2048
    timeout_s: float = 120.0


@dataclass
class AgentResult:
    answer: str = ""
    error: str | None = None
    rounds: int = 0


def _post_chat(
    config: AgentConfig,
    messages: list[dict[str, Any]],
    tools: list[dict[str, Any]],
    *,
    stream: bool,
) -> Any:
    url = config.base_url.rstrip("/") + "/chat/completions"
    body: dict[str, Any] = {
        "model": config.model,
        "messages": messages,
        "temperature": config.temperature,
        "max_tokens": config.max_tokens,
        "stream": stream,
    }
    if tools:
        body["tools"] = tools
        body["tool_choice"] = "auto"
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer local",
        },
        method="POST",
    )
    return urllib.request.urlopen(req, timeout=config.timeout_s)


def _parse_sse_stream(
    resp: Any,
    *,
    on_content: Callable[[str], None] | None = None,
) -> tuple[str, list[dict[str, Any]], str | None]:
    """Parse OpenAI SSE stream → (content, tool_calls, finish_reason)."""
    content_parts: list[str] = []
    tool_acc: dict[int, dict[str, str]] = {}
    finish_reason: str | None = None

    while True:
        raw = resp.readline()
        if not raw:
            break
        line = raw.decode("utf-8", errors="replace").strip()
        if not line or line.startswith(":"):
            continue
        if not line.startswith("data:"):
            continue
        payload = line[5:].strip()
        if payload == "[DONE]":
            break
        try:
            chunk = json.loads(payload)
        except json.JSONDecodeError:
            continue
        choice = (chunk.get("choices") or [{}])[0]
        delta = choice.get("delta") or {}
        finish_reason = choice.get("finish_reason") or finish_reason

        piece = delta.get("content")
        if piece:
            content_parts.append(piece)
            if on_content:
                on_content(piece)

        for tc in delta.get("tool_calls") or []:
            idx = int(tc.get("index", 0))
            entry = tool_acc.setdefault(
                idx, {"id": "", "name": "", "arguments": ""}
            )
            if tc.get("id"):
                entry["id"] = tc["id"]
            fn = tc.get("function") or {}
            if fn.get("name"):
                entry["name"] = fn["name"]
            if fn.get("arguments"):
                entry["arguments"] += fn["arguments"]

    tool_calls = []
    for idx in sorted(tool_acc):
        entry = tool_acc[idx]
        if not entry.get("name"):
            continue
        tool_calls.append(
            {
                "id": entry["id"] or f"call_{idx}",
                "type": "function",
                "function": {
                    "name": entry["name"],
                    "arguments": entry["arguments"] or "{}",
                },
            }
        )
    return "".join(content_parts), tool_calls, finish_reason


def _chat_once(
    config: AgentConfig,
    messages: list[dict[str, Any]],
    tools: list[dict[str, Any]],
    *,
    on_content: Callable[[str], None] | None = None,
) -> tuple[str, list[dict[str, Any]]]:
    try:
        resp = _post_chat(config, messages, tools, stream=True)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")[:500]
        raise RuntimeError(f"HTTP {exc.code} from LLM: {detail}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(
            f"Cannot reach LLM at {config.base_url}: {exc.reason}. "
            "Is llama-swap running?"
        ) from exc

    with resp:
        content, tool_calls, _finish = _parse_sse_stream(
            resp, on_content=on_content
        )
    return content, tool_calls


def run_agent(
    question: str,
    config: AgentConfig | None = None,
    callbacks: AgentCallbacks | None = None,
) -> AgentResult:
    config = config or AgentConfig()
    cb = callbacks or AgentCallbacks()
    tools = openai_tool_schemas(include_web=config.include_web)
    messages: list[dict[str, Any]] = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": question},
    ]
    result = AgentResult()

    if cb.on_status:
        cb.on_status(f"Asking {config.model}…")

    try:
        for round_i in range(1, config.max_rounds + 1):
            result.rounds = round_i
            if cb.on_status:
                cb.on_status(
                    f"{config.model} · round {round_i}/{config.max_rounds}"
                )

            # Buffer the round. Stream live to on_delta only for the final
            # answer (no tool_calls). Tool-round content goes to on_preamble.
            buffered: list[str] = []

            def on_content(piece: str, buf: list[str] = buffered) -> None:
                buf.append(piece)

            content, tool_calls = _chat_once(
                config,
                messages,
                tools,
                on_content=on_content,
            )
            content = content or "".join(buffered)

            if tool_calls:
                if content and cb.on_preamble:
                    cb.on_preamble(content)
                messages.append(
                    {
                        "role": "assistant",
                        "content": content or None,
                        "tool_calls": tool_calls,
                    }
                )
                for tc in tool_calls:
                    fn = tc.get("function") or {}
                    name = fn.get("name") or "unknown"
                    raw_args = fn.get("arguments") or "{}"
                    call_id = tc.get("id") or name
                    try:
                        args_obj = (
                            json.loads(raw_args) if raw_args.strip() else {}
                        )
                    except json.JSONDecodeError:
                        args_obj = {"_raw": raw_args}
                    if cb.on_tool_start:
                        cb.on_tool_start(call_id, name, args_obj)
                    ok, tool_out = run_tool(name, raw_args)
                    if cb.on_tool_end:
                        cb.on_tool_end(call_id, ok, tool_out)
                    messages.append(
                        {
                            "role": "tool",
                            "tool_call_id": call_id,
                            "content": tool_out,
                        }
                    )
                continue

            # Final answer — feed to typewriter / plain stdout.
            from ask.markdown_format import tag_code_fences

            result.answer = tag_code_fences(
                content.strip() or "(no response from model)"
            )
            if cb.on_delta and result.answer:
                cb.on_delta(result.answer)
            if cb.on_status:
                cb.on_status(f"Done ({config.model})")
            return result

        result.error = f"stopped after {config.max_rounds} tool rounds"
        result.answer = result.error
        return result
    except RuntimeError as exc:
        result.error = str(exc)
        result.answer = result.error
        if cb.on_delta:
            cb.on_delta(result.answer)
        return result


def run_agent_plain(
    question: str,
    config: AgentConfig | None = None,
    *,
    verbose: bool = False,
) -> AgentResult:
    """Run without Textual; print answer to stdout."""
    import sys

    from ask.tool_labels import done_label, running_label

    streamed = False
    tool_meta: dict[str, tuple[str, dict[str, Any]]] = {}

    def on_delta(text: str) -> None:
        nonlocal streamed
        streamed = True
        from ask.markdown_format import print_rich_markdown

        print_rich_markdown(text)

    def on_tool_start(call_id: str, name: str, args: dict[str, Any]) -> None:
        tool_meta[call_id] = (name, args)
        if verbose:
            sys.stderr.write(f"… {running_label(name, args)}\n")
            sys.stderr.flush()

    def on_tool_end(call_id: str, ok: bool, detail: str) -> None:
        if verbose:
            name, args = tool_meta.get(call_id, ("unknown", {}))
            sys.stderr.write(f"{done_label(name, args, ok=ok)}\n")
            sys.stderr.flush()

    result = run_agent(
        question,
        config=config,
        callbacks=AgentCallbacks(
            on_delta=on_delta,
            on_tool_start=on_tool_start,
            on_tool_end=on_tool_end,
        ),
    )
    if not streamed and result.answer:
        from ask.markdown_format import print_rich_markdown

        print_rich_markdown(result.answer)
    return result
