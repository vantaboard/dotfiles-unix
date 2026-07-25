"""ask CLI entrypoint."""

from __future__ import annotations

import argparse
import sys

from ask.agent import (
    DEFAULT_BASE_URL,
    DEFAULT_MAX_ROUNDS,
    DEFAULT_MODEL,
    AgentConfig,
)


def _read_question(args: argparse.Namespace) -> str:
    parts = list(args.question or [])
    if parts == ["-"] or (not parts and not sys.stdin.isatty()):
        return sys.stdin.read().strip()
    return " ".join(parts).strip()


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="ask",
        description=(
            "Ask your local LLM (llama-swap) a question. Uses allowlisted "
            "tools (which/type, man, --help) and optional DuckDuckGo search."
        ),
    )
    p.add_argument(
        "question",
        nargs="*",
        help="Question to ask (use - to read stdin)",
    )
    p.add_argument(
        "--web",
        action="store_true",
        help="Enable DuckDuckGo web_search tool",
    )
    p.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"Model alias (default: {DEFAULT_MODEL})",
    )
    p.add_argument(
        "--base-url",
        default=DEFAULT_BASE_URL,
        help=f"OpenAI-compatible base URL (default: {DEFAULT_BASE_URL})",
    )
    p.add_argument(
        "--max-rounds",
        type=int,
        default=DEFAULT_MAX_ROUNDS,
        help=f"Max tool rounds (default: {DEFAULT_MAX_ROUNDS})",
    )
    p.add_argument(
        "--plain",
        action="store_true",
        help="Disable Textual UI (plain stdout)",
    )
    p.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Show tool argument/result detail",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    question = _read_question(args)
    if not question:
        print("ask: missing question", file=sys.stderr)
        return 2

    config = AgentConfig(
        base_url=args.base_url,
        model=args.model,
        max_rounds=max(1, args.max_rounds),
        include_web=args.web,
    )

    from ask.tui import run_ask_tui

    answer = run_ask_tui(
        question,
        config,
        verbose=args.verbose,
        use_textual=False if args.plain else None,
    )
    # Textual inline mode leaves the answer on screen; plain already printed.
    # Exit 1 on transport/agent errors.
    if answer.startswith("Cannot reach LLM") or answer.startswith("HTTP "):
        return 1
    if answer.startswith("error:"):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
