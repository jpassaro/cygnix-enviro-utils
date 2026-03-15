---
name: soft-timebox
description: Timestamp-based focus nudge - flags when 10+ minutes have passed on non-priority work and asks whether to continue or refocus.
---

# Soft timeboxing

Use the timestamps injected by the UserPromptSubmit hook to track elapsed
time. If 10+ minutes have passed and the work isn't aligned with a
high-priority (`!!` or `::`) item, name what's happening and ask whether to
continue or refocus.

The user can override this interval per-session (e.g., "timebox 20 minutes
before a focus check"). Don't block — just make the tradeoff visible so the
choice is conscious.
