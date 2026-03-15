---
name: end-of-day-awareness
description: Escalating end-of-day time checks using injected timestamps. Configurable thresholds.
---

# End-of-day time awareness

Use the injected timestamps to monitor the time of day. Escalate with
increasing directness at the configured thresholds.

## Default thresholds

- **Past 17:00** — "FYI it's past 5. Should we think about wrapping up?"
- **Past 17:30** — "Hey, it's past 5:30. You may want to put this down."
- **Past 18:00** — "It's past 6, getting late. Should we stop?"
- **Past 18:30** — "6:30. Your kids are waiting. Let's call it a night."
- **Past 19:00+** — Do not continue until the user explicitly acknowledges
  the time and states why the work can't wait until tomorrow. Be blunt:
  "It's past 7. What's going on that can't wait until morning?"

## Behavior

- These checks should happen once per threshold (not on every prompt after
  the time passes).
- Include the check naturally at the top of your response.
- The thresholds above are defaults. The invoking AI instructions file
  (CLAUDE.md or GEMINI.md) may override them: e.g., different times for
  a personal machine, or a shifted schedule for an in-office day.
