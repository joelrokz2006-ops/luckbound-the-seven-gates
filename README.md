# LUCKBOUND: The Seven Gates

[![Godot](https://img.shields.io/badge/Godot-4.3--stable-blue.svg)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSES.md)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Desktop%20%7C%20Web-brightgreen.svg)]()

> **Fictional-Score Safety Boundary:** This game uses **fictional virtual score only**. There are no real-money deposits, wagers, cash-outs, prizes, gift cards, crypto/NFT rewards, transferable tokens, paid chance entries, or purchaseable coins.

---

## 1. Overview

**LUCKBOUND: The Seven Gates** is a polished 2D luck-based fantasy arcade game built in **Godot 4.3 + GDScript**.

Players venture through an ancient floating sanctuary under an indigo night sky. In each round, three mystical gates appear: **Ember** (Flame), **Tide** (Water), and **Gale** (Wind). Selecting a gate reveals a celestial fate:
- **Starfall (45%)**: Awards the round base score multiplied by the current gate multiplier.
- **Lucky Echo (25%)**: Awards bonus score and increases the active streak counter (+1).
- **Guardian Sigil (15%)**: Grants 1 protective shield that guards unbanked score from a Void collapse.
- **Void (15%)**: Consumes the unbanked score unless deflected by a Guardian Shield.

After surviving a gate, players must decide:
- **Bank Run Score**: End the run voluntarily and secure all points to their local career record.
- **Continue**: Venture to the next gate with an increased multiplier (up to 2.0x at Gate 7).

---

## 2. Prerequisites & Engine Version

- **Engine:** Godot Engine 4.3 stable (`4.3.stable.official.77dcf97d8` or compatible 4.x release).
- **Graphics Renderer:** Compatibility (`gl_compatibility` / OpenGL 3.3 / WebGL 2).
- **Platform:** Linux (X11 & Wayland), macOS, Windows.

---

## 3. How to Launch & Play

### Running from the Command Line
To launch the game immediately:
```bash
# Launch the main game scene
godot scenes/main_menu.tscn

# Or from project root
godot
```

### Opening in the Godot Editor
1. Open the Godot 4.3 Project Manager.
2. Click **Import**.
3. Browse to this directory and select `project.godot`.
4. Click **Import & Edit**.
5. Press `F5` to run the project.

---

## 4. Controls & Accessibility

- **Mouse / Touch:** Click any gate or button.
- **Gate Shortcuts:**
  - `1`: Select Ember Gate
  - `2`: Select Tide Gate
  - `3`: Select Gale Gate
- **Decision Shortcuts:**
  - `Space` / `Enter`: Continue to Next Gate / Confirm
  - `B`: Bank Run Score
  - `Esc`: Pause / Back to Menu
- **Accessibility Options (Settings Menu):**
  - **Reduced Motion:** Minimizes fast particle bursts and screen flashes.
  - **High Contrast:** Amplifies borders and text readability.
  - **Audio Sliders & Mute:** Independent controls for ambient music and sound effects.

---

## 5. Automated Tests & QA Simulation

### Running the Test Suite (Headless)
Execute the comprehensive test runner verifying RNG statistical distribution (10,000 trials), deterministic forcing, scoring multipliers, shield deflection, and save corruption resilience:
```bash
godot --headless --script tests_or_debug/rng_test_runner.gd
```

### Running the Full Gameplay Simulation
Execute a 100-run automated gameplay simulation to inspect score distributions, win rates, and shield deflection statistics:
```bash
godot --headless --script tests_or_debug/run_simulation.gd
```

### In-Game Developer QA Controls
During any game run, press `F1` to toggle the QA Debug Overlay. This allows forcing specific outcomes (**Starfall**, **Lucky Echo**, **Guardian Sigil**, or **Void**) in real time to verify animations and mechanics.

---

## 6. Configuring Rules & Probabilities

All game balance parameters are centralized in configuration resources:

- **Outcome Probabilities:** `resources/outcome_table.tres`
  - `starfall_weight = 0.45` (45%)
  - `lucky_echo_weight = 0.25` (25%)
  - `guardian_sigil_weight = 0.15` (15%)
  - `void_weight = 0.15` (15%)
- **Scoring & Multipliers:** `resources/game_config.tres`
  - `base_reward = 100`
  - `echo_reward = 50`
  - `max_rounds = 7`
  - `round_multipliers = [1.0, 1.0, 1.25, 1.25, 1.5, 1.5, 2.0]`

---

## 7. Architecture & Code Structure

```text
├── project.godot                     # Godot 4 engine project configuration
├── README.md                         # Documentation and user guide
├── LICENSES.md                       # Open source & attribution details
├── CHANGELOG.md                      # Milestone change log
├── assets/                           # Audio, art, fonts, and icon assets
├── scenes/
│   └── main_menu.tscn                # Main entrance scene
├── scripts/
│   ├── app.gd                        # Master scene and service coordinator
│   ├── game_controller.gd            # Gameplay state machine & HUD manager
│   ├── gate_controller.gd            # Elemental gate visuals & input handler
│   ├── outcome_service.gd            # Isolated RNG outcome selector
│   ├── scoring_service.gd            # Multiplier, streak, and shield logic
│   ├── save_service.gd               # Local JSON persistence & error recovery
│   ├── settings_service.gd           # User preferences manager
│   ├── procedural_audio.gd           # 16-bit procedural waveform synthesizer
│   ├── audio_service.gd              # Audio player & mixer manager
│   ├── celestial_background.gd       # Parallax starfield & floating ruins
│   ├── main_menu.gd                  # Title screen UI
│   ├── result_reveal.gd              # Fate animation & decision modal
│   ├── run_end.gd                    # Run completion & statistics screen
│   ├── how_to_play.gd                # Interactive rules guide
│   ├── settings_screen.gd            # Settings configuration UI
│   └── credits_screen.gd             # Credits and legal disclosures
├── resources/
│   ├── outcome_table.tres            # Probability configuration resource
│   └── game_config.tres              # Scoring configuration resource
└── tests_or_debug/
    ├── rng_test_runner.gd            # Headless automated test suite
    └── run_simulation.gd             # 100-run Monte Carlo gameplay simulator
```

---

## 8. Exporting the Project

To export for Linux, Windows, or HTML5 Web:
1. Ensure the desired Godot 4.3 export template is installed.
2. In the Godot editor, select **Project -> Export...**
3. Choose the export preset (e.g. `Linux/X11` or `Web`).
4. Click **Export Project**.

---

## 9. Licenses & Credits

- Code and visual art are licensed under the **MIT License**.
- Procedural audio waveforms are original and licensed under **CC0 1.0 Universal**.
- See [LICENSES.md](LICENSES.md) for full attribution.
