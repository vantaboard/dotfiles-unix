"""Thinking-style activity animation (not a loading spinner)."""

from __future__ import annotations

# Soft sparkle pulse — reads as "pondering" rather than "busy spinner".
THINK_FRAMES: tuple[str, ...] = ("⋆", "✶", "✦", "✧", "✦", "✶")

# Bouncing dots used in plain/verbose stderr (ASCII-safe fallback).
THINK_DOTS: tuple[str, ...] = ("∙∙∙", "●∙∙", "∙●∙", "∙∙●", "∙●∙", "●∙∙")


def think_frame(index: int) -> str:
    return THINK_FRAMES[index % len(THINK_FRAMES)]


def think_dots(index: int) -> str:
    return THINK_DOTS[index % len(THINK_DOTS)]
