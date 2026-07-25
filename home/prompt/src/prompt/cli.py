"""prompt CLI entrypoint."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from prompt.agent import (
    DEFAULT_BASE_URL,
    DEFAULT_MAX_ROUNDS,
    DEFAULT_MODEL,
    AgentConfig,
)
from prompt.debug import DEFAULT_DEBUG_LOG, DebugLog
from prompt.history import (
    HISTORY_PATH,
    HistoryError,
    append_exchange,
    clear_history,
    messages_from_entry,
    print_history,
    resolve_history_ref,
    short_id,
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

    from prompt.tui import prompt_for_question

    return prompt_for_question(use_textual=False if args.plain else None)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="prompt",
        description=(
            "Prompt your local LLM (llama-swap). Uses allowlisted tools "
            "(which/type, man, --help) and DuckDuckGo when helpful. "
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
    p.add_argument(
        "--debug",
        action="store_true",
        help=(
            "Write a detailed JSONL trace to the debug log "
            f"(default: {DEFAULT_DEBUG_LOG})"
        ),
    )
    p.add_argument(
        "--debug-log",
        metavar="PATH",
        help=(
            "Debug log path (implies --debug). "
            "Also set via PROMPT_DEBUG_LOG."
        ),
    )
    p.add_argument(
        "--history",
        nargs="?",
        const=20,
        type=int,
        metavar="N",
        help=(
            f"Show the last N Q&A exchanges (default 20) from {HISTORY_PATH} "
            "and exit"
        ),
    )
    p.add_argument(
        "--history-clear",
        action="store_true",
        help="Delete saved Q&A history and exit",
    )
    p.add_argument(
        "--no-history",
        action="store_true",
        help="Do not append this exchange to history",
    )
    p.add_argument(
        "--follow-up",
        "--followup",
        nargs="?",
        const="",
        default=None,
        metavar="REF",
        help=(
            "Continue a prior prompt: index (#N from --history), UUID / unique "
            "prefix, or omit REF to follow up on the latest entry"
        ),
    )
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    if args.history_clear:
        if clear_history():
            print(f"prompt: cleared {HISTORY_PATH}", file=sys.stderr)
        else:
            print(f"prompt: no history at {HISTORY_PATH}", file=sys.stderr)
        return 0

    if args.history is not None:
        print_history(args.history)
        return 0

    messages = None
    parent_id: str | None = None
    if args.follow_up is not None:
        try:
            entry, idx = resolve_history_ref(
                args.follow_up if args.follow_up != "" else None
            )
        except HistoryError as exc:
            print(f"prompt: {exc}", file=sys.stderr)
            return 2
        messages = messages_from_entry(entry)
        parent_id = str(entry.get("id") or "") or None
        eid = short_id(parent_id or "")
        label = f"#{idx}"
        if eid:
            label += f" {eid}"
        print(f"prompt: following up on {label}", file=sys.stderr)

    try:
        question = _read_question(args)
    except KeyboardInterrupt:
        print(file=sys.stderr)
        return 130
    if not question:
        # None → cancelled interactive prompt; "" → empty stdin/submit.
        if question is None and sys.stdin.isatty() and not args.question:
            return 130
        print("prompt: missing question", file=sys.stderr)
        return 2

    debug: DebugLog | None = None
    if args.debug or args.debug_log:
        path = Path(args.debug_log) if args.debug_log else DEFAULT_DEBUG_LOG
        debug = DebugLog(path)
        print(f"prompt: debug log -> {debug.path}", file=sys.stderr)

    config = AgentConfig(
        base_url=args.base_url,
        model=args.model,
        max_rounds=max(1, args.max_rounds),
        include_web=bool(args.web),
        debug=debug,
    )

    from prompt.agent import answer_awaits_reply
    from prompt.tui import prompt_for_question, run_prompt_turn

    current: str | None = question
    exit_code = 0
    try:
        while current:
            result = run_prompt_turn(
                current,
                config,
                messages=messages,
                verbose=args.verbose,
                use_textual=False if args.plain else None,
            )
            messages = result.messages or messages
            answer = result.answer or ""
            is_error = bool(
                result.error
                or answer.startswith("Cannot reach LLM")
                or answer.startswith("HTTP ")
                or answer.startswith("error:")
            )
            if not args.no_history and answer:
                try:
                    new_id = append_exchange(
                        current,
                        answer,
                        model=config.model,
                        base_url=config.base_url,
                        include_web=config.include_web,
                        error=is_error,
                        parent_id=parent_id,
                    )
                    parent_id = new_id
                    if sys.stderr.isatty():
                        print(
                            f"prompt: saved {short_id(new_id)}",
                            file=sys.stderr,
                        )
                except OSError as exc:
                    print(
                        f"prompt: failed to write history: {exc}",
                        file=sys.stderr,
                    )
            if is_error:
                exit_code = 1
                break
            if not answer_awaits_reply(answer):
                break
            if not (
                sys.stdin.isatty()
                and sys.stdout.isatty()
            ):
                break
            follow = prompt_for_question(
                use_textual=False if args.plain else None
            )
            if not follow:
                break
            current = follow
    except KeyboardInterrupt:
        print(file=sys.stderr)
        if debug is not None:
            debug.log("interrupted")
        return 130
    finally:
        if debug is not None:
            debug.close()

    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
