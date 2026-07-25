"""Adaptive catch-up typewriter for streamed Markdown (Textual / CLI).

Adapted from job-tracking's AdaptiveTypewriter: reveal already-buffered text
at a readable pace, accelerate via a lag-driven cubic-bezier curve when
chunks pile up or the stream finishes.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class TypewriterOptions:
    min_cps: float = 42.0
    max_cps: float = 900.0
    catch_up_threshold: float = 120.0
    done_max_cps: float = 2400.0
    p1x: float = 0.15
    p1y: float = 0.0
    p2x: float = 0.85
    p2y: float = 1.0


def _clamp(value: float, lo: float, hi: float) -> float:
    return min(hi, max(lo, value))


def cubic_bezier_y(
    t: float,
    p1x: float,
    p1y: float,
    p2x: float,
    p2y: float,
) -> float:
    """Sample CSS-style cubic-bezier y for progress ``t`` in [0, 1]."""
    cx = 3.0 * p1x
    bx = 3.0 * (p2x - p1x) - cx
    ax = 1.0 - cx - bx
    cy = 3.0 * p1y
    by = 3.0 * (p2y - p1y) - cy
    ay = 1.0 - cy - by

    def sample_x(u: float) -> float:
        return ((ax * u + bx) * u + cx) * u

    def sample_y(u: float) -> float:
        return ((ay * u + by) * u + cy) * u

    def sample_dx(u: float) -> float:
        return (3.0 * ax * u + 2.0 * bx) * u + cx

    u = t
    for _ in range(6):
        x = sample_x(u) - t
        if abs(x) < 1e-5:
            break
        dx = sample_dx(u)
        if abs(dx) < 1e-6:
            break
        u -= x / dx
    u = _clamp(u, 0.0, 1.0)
    return sample_y(u)


def chars_per_second(
    lag: float,
    *,
    done: bool = False,
    opts: TypewriterOptions | None = None,
) -> float:
    options = opts or TypewriterOptions()
    if lag <= 0:
        return 0.0
    max_cps = options.done_max_cps if done else options.max_cps
    u = _clamp(lag / options.catch_up_threshold, 0.0, 1.0)
    eased = cubic_bezier_y(
        u, options.p1x, options.p1y, options.p2x, options.p2y
    )
    return options.min_cps + (max_cps - options.min_cps) * eased


@dataclass
class AdaptiveTypewriter:
    """Buffer streamed text and drip reveal slices on each tick."""

    opts: TypewriterOptions = field(default_factory=TypewriterOptions)
    target: str = ""
    cursor: float = 0.0
    done: bool = False

    def extend_target(self, chunk: str) -> None:
        if chunk:
            self.target += chunk

    def mark_done(self) -> None:
        self.done = True

    def snap(self) -> str:
        """Reveal everything remaining (reduced-motion / flush)."""
        start = int(self.cursor)
        self.cursor = float(len(self.target))
        return self.target[start:]

    @property
    def lag(self) -> float:
        return len(self.target) - self.cursor

    @property
    def caught_up(self) -> bool:
        return self.cursor >= len(self.target)

    def tick(self, dt_s: float) -> str:
        """Advance by ``dt_s`` seconds; return newly revealed text."""
        prev = int(self.cursor)
        lag = self.lag
        if lag <= 0 or dt_s <= 0:
            self.cursor = min(self.cursor, float(len(self.target)))
            return ""
        speed = chars_per_second(lag, done=self.done, opts=self.opts)
        self.cursor = min(
            float(len(self.target)),
            self.cursor + speed * dt_s,
        )
        next_i = int(self.cursor)
        if next_i <= prev:
            return ""
        return self.target[prev:next_i]


__all__ = [
    "AdaptiveTypewriter",
    "TypewriterOptions",
    "chars_per_second",
    "cubic_bezier_y",
]
