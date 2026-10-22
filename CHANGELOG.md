# Changelog

All notable changes to **LUCKBOUND: The Seven Gates** will be documented in this file.

## [1.0.0] - 2026-10-22

### Milestone 0: Concept & Boundary
- Established core 7-gate fantasy luck arcade loop.
- Enforced strict fictional-score-only boundary (no real money, deposits, prizes, or wagers).

### Milestone 1: Playable Skeleton
- Configured Godot 4.3 project with `gl_compatibility` 2D rendering and responsive aspect handling.
- Implemented core application coordinator (`App`) and game state machine (`MENU`, `READY`, `REVEALING`, `DECISION`, `RUN_ENDED`).
- Added 3 interactive gate archetypes: Ember (Flame), Tide (Water), and Gale (Wind).
- Implemented immediate input lock on gate selection to prevent race conditions or double clicks.

### Milestone 2: Rules & Testable Randomness
- Implemented isolated outcome service (`OutcomeService`) with validated weights:
  - Starfall: 45% (Base 100 * Multiplier)
  - Lucky Echo: 25% (Base 50 * Multiplier, Streak +1)
  - Guardian Sigil: 15% (Shield protection)
  - Void: 15% (Clears unbanked score unless shielded)
- Built progressive scoring multiplier tiers:
  - Gates 1–2: 1.0x
  - Gates 3–4: 1.25x
  - Gates 5–6: 1.5x
  - Gate 7: 2.0x
- Created headless automated test runner (`rng_test_runner.gd`) verifying weight validation, 10,000-trial statistical distribution, deterministic modes, shield deflection, and scoring math.

### Milestone 3: Feel & Visual Polish
- Created custom procedural vector gate rendering with animated elemental runes and particle motes.
- Built dynamic celestial night sky with twinkling stars, drifting cosmic dust, and floating island silhouettes.
- Implemented dramatic fate reveal sequences with particle bursts, flash effects, and outcome animations.
- Developed real-time mathematical procedural audio synthesizer (`ProceduralAudio`) providing 10 unique SFX and a looping celestial ambient soundtrack with zero external dependencies.
- Added reduced-motion support to respect player accessibility preferences.

### Milestone 4: Persistence & Settings
- Implemented local JSON save manager (`SaveService`) tracking career personal best, runs banked, and streaks with automatic recovery from malformed or corrupted save files.
- Implemented comprehensive settings manager (`SettingsService`) with independent music and SFX volume sliders, audio mutes, reduced-motion toggle, and high-contrast mode.

### Milestone 5: QA & Balance
- Added developer QA debug overlay (toggled with `F1`) allowing deterministic forcing of any outcome in real time.
- Ran 100-run automated gameplay simulation (`run_simulation.gd`) confirming 0 crashes, balanced survival rates (~58% banked rate), and average run length of 4.18 gates.
- Verified mouse, touchscreen, and full keyboard navigation (Keys 1/2/3 for gates, Space/Enter for continue, B for bank, Esc for back).

### Milestone 6: Release Gate
- Complete documentation in `README.md`, `LICENSES.md`, and in-game Credits & Legal Disclosures screen.
