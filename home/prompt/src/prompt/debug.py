"""Thread-safe debug trace log for prompt runs."""

from __future__ import annotations

import json
import os
import threading
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


DEFAULT_DEBUG_LOG = Path(
    os.environ.get("PROMPT_DEBUG_LOG", "")
    or (Path.home() / ".cache" / "prompt" / "debug.log")
)


class DebugLog:
    """Append-only JSON-lines debug log with wall-clock and elapsed timing."""

    def __init__(self, path: Path | str) -> None:
        self.path = Path(path).expanduser()
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._lock = threading.Lock()
        self._t0 = time.monotonic()
        self._fh = self.path.open("a", encoding="utf-8")
        self.log("session_open", path=str(self.path))

    def close(self) -> None:
        with self._lock:
            if self._fh.closed:
                return
            self._write_unlocked(
                "session_close",
                elapsed_s=round(time.monotonic() - self._t0, 3),
            )
            self._fh.close()

    def __enter__(self) -> DebugLog:
        return self

    def __exit__(self, *exc: object) -> None:
        self.close()

    def log(self, event: str, **fields: Any) -> None:
        with self._lock:
            if self._fh.closed:
                return
            self._write_unlocked(event, **fields)

    def _write_unlocked(self, event: str, **fields: Any) -> None:
        record = {
            "ts": datetime.now(timezone.utc).isoformat(timespec="milliseconds"),
            "t": round(time.monotonic() - self._t0, 3),
            "event": event,
            **fields,
        }
        line = json.dumps(record, ensure_ascii=False, default=str)
        self._fh.write(line + "\n")
        self._fh.flush()


def truncate(text: str, limit: int = 2000) -> str:
    text = text or ""
    if len(text) <= limit:
        return text
    return text[: limit - 16] + "...[truncated]"
