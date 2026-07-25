"""Persistent prompt Q&A history (JSONL) and interactive input history."""

from __future__ import annotations

import fcntl
import json
import os
import threading
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator


def _data_dir() -> Path:
    override = os.environ.get("PROMPT_DATA_DIR", "").strip()
    if override:
        return Path(override).expanduser()
    xdg = os.environ.get("XDG_DATA_HOME", "").strip()
    if xdg:
        return Path(xdg).expanduser() / "prompt"
    return Path.home() / ".local" / "share" / "prompt"


DATA_DIR = _data_dir()
HISTORY_PATH = Path(
    os.environ.get("PROMPT_HISTORY", "") or (DATA_DIR / "history.jsonl")
)
INPUT_HISTORY_PATH = Path(
    os.environ.get("PROMPT_INPUT_HISTORY", "") or (DATA_DIR / "input_history")
)

_lock = threading.Lock()


class HistoryError(Exception):
    """Invalid or ambiguous history reference."""


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def short_id(entry_id: str, *, length: int = 8) -> str:
    return (entry_id or "")[:length]


def append_exchange(
    question: str,
    answer: str,
    *,
    model: str = "",
    base_url: str = "",
    include_web: bool = True,
    rounds: int = 0,
    error: bool = False,
    parent_id: str | None = None,
    entry_id: str | None = None,
) -> str:
    """Append one Q&A exchange; return its UUID.

    Uses an exclusive file lock so concurrent ``prompt`` processes can append
    safely to the same JSONL file.
    """
    _ensure_parent(HISTORY_PATH)
    eid = entry_id or str(uuid.uuid4())
    record: dict[str, Any] = {
        "id": eid,
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "question": question,
        "answer": answer,
        "model": model,
        "base_url": base_url,
        "include_web": include_web,
        "rounds": rounds,
        "error": error,
    }
    if parent_id:
        record["parent_id"] = parent_id
    line = json.dumps(record, ensure_ascii=False) + "\n"
    data = line.encode("utf-8")
    with _lock:
        fd = os.open(
            HISTORY_PATH,
            os.O_WRONLY | os.O_CREAT | os.O_APPEND,
            0o644,
        )
        try:
            fcntl.flock(fd, fcntl.LOCK_EX)
            try:
                os.write(fd, data)
                os.fsync(fd)
            finally:
                fcntl.flock(fd, fcntl.LOCK_UN)
        finally:
            os.close(fd)
    return eid


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


def find_by_id(entry_id: str) -> dict[str, Any] | None:
    """Return the entry with exact ``id``, or None."""
    if not entry_id:
        return None
    for entry in iter_history():
        if entry.get("id") == entry_id:
            return entry
    return None


def resolve_history_ref(ref: str | None) -> tuple[dict[str, Any], int]:
    """Resolve a follow-up ref to ``(entry, 1-based index)``.

    ``ref`` may be:
    - ``None`` / ``""`` — latest entry
    - decimal index (``21``) — 1-based position in the file
    - full UUID or unique prefix
    """
    entries = list(iter_history())
    if not entries:
        raise HistoryError(f"no history yet — {HISTORY_PATH}")

    if ref is None or str(ref).strip() == "":
        return entries[-1], len(entries)

    token = str(ref).strip()
    if token.isdigit():
        idx = int(token)
        if idx < 1 or idx > len(entries):
            raise HistoryError(
                f"no history entry #{idx} (have {len(entries)})"
            )
        return entries[idx - 1], idx

    # UUID / unique prefix (ignore entries that predate ids).
    matches: list[tuple[dict[str, Any], int]] = []
    for i, entry in enumerate(entries, start=1):
        eid = str(entry.get("id") or "")
        if not eid:
            continue
        if eid == token or eid.startswith(token):
            matches.append((entry, i))
    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        shown = ", ".join(short_id(e.get("id", "")) for e, _ in matches[:5])
        raise HistoryError(
            f"ambiguous id prefix {token!r} matches {len(matches)} "
            f"entries ({shown}...)"
        )
    raise HistoryError(f"no history entry matching {token!r}")


def followup_chain(entry: dict[str, Any]) -> list[dict[str, Any]]:
    """Return parent→…→entry chain (oldest first), capped against cycles."""
    by_id = {
        str(e["id"]): e
        for e in iter_history()
        if e.get("id")
    }
    chain: list[dict[str, Any]] = []
    seen: set[str] = set()
    cur: dict[str, Any] | None = entry
    while cur is not None:
        eid = str(cur.get("id") or "")
        chain.append(cur)
        if eid:
            if eid in seen:
                break
            seen.add(eid)
        parent = cur.get("parent_id")
        if not parent:
            break
        cur = by_id.get(str(parent))
    chain.reverse()
    return chain


def messages_from_entry(entry: dict[str, Any]) -> list[dict[str, Any]]:
    """Build chat messages to continue from ``entry`` (including parents)."""
    from prompt.tools import SYSTEM_PROMPT

    messages: list[dict[str, Any]] = [
        {"role": "system", "content": SYSTEM_PROMPT}
    ]
    for item in followup_chain(entry):
        q = (item.get("question") or "").strip()
        a = (item.get("answer") or "").strip()
        if q:
            messages.append({"role": "user", "content": q})
        if a:
            messages.append({"role": "assistant", "content": a})
    return messages


def format_history_entry(entry: dict[str, Any], *, index: int) -> str:
    ts = entry.get("ts") or ""
    q = (entry.get("question") or "").strip()
    a = (entry.get("answer") or "").strip()
    model = entry.get("model") or ""
    err = " [error]" if entry.get("error") else ""
    eid = short_id(str(entry.get("id") or ""))
    header = f"#{index}"
    if eid:
        header += f" {eid}"
    header += f" {ts}{err}"
    if model:
        header += f" · {model}"
    parent = entry.get("parent_id")
    if parent:
        header += f" · follow-up of {short_id(str(parent))}"
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
    """Load/save interactive ``prompt>`` line history via readline."""
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
