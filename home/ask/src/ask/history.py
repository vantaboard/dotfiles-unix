"""Persistent ask Q&A history (JSONL) and interactive input history."""

from __future__ import annotations

import json
import os
import threading
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator


def _data_dir() -> Path:
    override = os.environ.get("ASK_DATA_DIR", "").strip()
    if override:
        return Path(override).expanduser()
    xdg = os.environ.get("XDG_DATA_HOME", "").strip()
    if xdg:
        return Path(xdg).expanduser() / "ask"
    return Path.home() / ".local" / "share" / "ask"


DATA_DIR = _data_dir()
HISTORY_PATH = Path(
    os.environ.get("ASK_HISTORY", "") or (DATA_DIR / "history.jsonl")
)
INPUT_HISTORY_PATH = Path(
    os.environ.get("ASK_INPUT_HISTORY", "") or (DATA_DIR / "input_history")
)

_lock = threading.Lock()


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def append_exchange(
    question: str,
    answer: str,
    *,
    model: str = "",
    base_url: str = "",
    include_web: bool = True,
    rounds: int = 0,
    error: bool = False,
) -> Path:
    """Append one Q&A exchange to the history JSONL file."""
    _ensure_parent(HISTORY_PATH)
    record: dict[str, Any] = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "question": question,
        "answer": answer,
        "model": model,
        "base_url": base_url,
        "include_web": include_web,
        "rounds": rounds,
        "error": error,
    }
    line = json.dumps(record, ensure_ascii=False) + "\n"
    with _lock:
        with HISTORY_PATH.open("a", encoding="utf-8") as fh:
            fh.write(line)
    return HISTORY_PATH


def iter_history() -> Iterator[dict[str, Any]]:
    """Yield history records oldest-first."""
    if not HISTORY_PATH.is_file():
        return
    with HISTORY_PATH.open(encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def recent_history(limit: int = 20) -> list[dict[str, Any]]:
    """Return the newest ``limit`` exchanges (newest last)."""
    limit = max(1, limit)
    items = list(iter_history())
    return items[-limit:]


def clear_history() -> bool:
    """Delete the Q&A history file. Returns True if a file was removed."""
    with _lock:
        if HISTORY_PATH.is_file():
            HISTORY_PATH.unlink()
            return True
    return False


def format_history_entry(entry: dict[str, Any], *, index: int) -> str:
    ts = entry.get("ts") or ""
    q = (entry.get("question") or "").strip()
    a = (entry.get("answer") or "").strip()
    model = entry.get("model") or ""
    err = " [error]" if entry.get("error") else ""
    header = f"#{index} {ts}{err}"
    if model:
        header += f" · {model}"
    parts = [header, f"Q: {q}", f"A: {a}"]
    return "\n".join(parts)


def print_history(limit: int = 20, *, file: Any = None) -> int:
    """Print recent history to ``file`` (default stdout). Returns count."""
    import sys

    out = file or sys.stdout
    all_entries = list(iter_history())
    if not all_entries:
        print(f"(no history yet — {HISTORY_PATH})", file=out)
        return 0
    entries = all_entries[-max(1, limit) :]
    total = len(all_entries)
    for i, entry in enumerate(reversed(entries)):
        idx = total - i
        print(format_history_entry(entry, index=idx), file=out)
        print(file=out)
    print(f"({len(entries)} shown · {HISTORY_PATH})", file=out)
    return len(entries)


def setup_readline_history() -> None:
    """Load/save interactive ``ask>`` line history via readline."""
    try:
        import readline
    except ImportError:
        return

    _ensure_parent(INPUT_HISTORY_PATH)
    try:
        if INPUT_HISTORY_PATH.is_file():
            readline.read_history_file(str(INPUT_HISTORY_PATH))
    except OSError:
        pass
    try:
        readline.set_history_length(1000)
    except AttributeError:
        pass

    def _save() -> None:
        try:
            readline.write_history_file(str(INPUT_HISTORY_PATH))
        except OSError:
            pass

    import atexit

    atexit.register(_save)
