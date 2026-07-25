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


def _read_question(args: argparse.Namespace) -> str | None:
    """Resolve the question from argv, stdin, or an interactive prompt.

    Returns None when the user cancels an interactive prompt.
    """
    parts = list(args.question or [])
    if parts == ["-"]:
        return sys.stdin.read().strip() or None
    if parts:
        return " ".join(parts).strip() or None
    # No argv question: pipe/redirect → stdin; TTY → interactive prompt.
    if not sys.stdin.isatty():
        return sys.stdin.read().strip() or None

    from ask.tui import prompt_for_question

    return prompt_for_question(use_textual=False if args.plain else None)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="ask",
        description=(
            "Ask your local LLM (llama-swap) a question. Uses allowlisted "
            "tools (which/type, man, --help) and DuckDuckGo when helpful. "
            "Run with no arguments to type the question interactively."
        ),
    )
    p.add_argument(
        "question",
        nargs="*",
        help="Question to ask (omit to type interactively; use - for stdin)",
    )
    web = p.add_mutually_exclusive_group()
    web.add_argument(
        "--web",
        action="store_true",
        default=True,
        help="Allow DuckDuckGo web_search when helpful (default)",
    )
    web.add_argument(
        "--no-web",
        action="store_false",
        dest="web",
        help="Disable web_search (local tools only)",
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
        help="Disable Textual UI (plain stdout / plain prompt)",
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
    try:
        question = _read_question(args)
    except KeyboardInterrupt:
        print(file=sys.stderr)
        return 130
    if not question:
        # None → cancelled interactive prompt; "" → empty stdin/submit.
        if question is None and sys.stdin.isatty() and not args.question:
            return 130
        print("ask: missing question", file=sys.stderr)
        return 2

    config = AgentConfig(
        base_url=args.base_url,
        model=args.model,
        max_rounds=max(1, args.max_rounds),
        include_web=bool(args.web),
    )

    from ask.tui import run_ask_tui

    try:
        answer = run_ask_tui(
            question,
            config,
            verbose=args.verbose,
            use_textual=False if args.plain else None,
        )
    except KeyboardInterrupt:
        print(file=sys.stderr)
        return 130
    # Textual inline mode leaves the answer on screen; plain already printed.
    # Exit 1 on transport/agent errors.
    if answer.startswith("Cannot reach LLM") or answer.startswith("HTTP "):
        return 1
    if answer.startswith("error:"):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
