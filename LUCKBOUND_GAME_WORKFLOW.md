# LUCKBOUND — 2D Luck-Based Game: Build Workflow

> **Purpose:** A build-ready product and implementation brief for an AI coding agent or solo developer.
>
> **Project type:** 2D, single-player, luck-driven arcade game.
>
> **Safety and release boundary:** The MVP uses **fictional score only**. No real-money deposits, wagers, cash-outs, prizes, gift cards, crypto/NFT rewards, transferable tokens, paid chance entries, or purchaseable coins. Do not add hidden routes to a real-money service, payment processors, or regional-restriction workarounds. Before adding monetisation or publishing in any country, stop for legal and platform-policy review.

---

## 1. Game concept

### Working title: **LUCKBOUND: The Seven Gates**

**One-line pitch:** Choose a glowing gate on a mysterious floating island, reveal a random fate, and decide whether to end the run with your score or risk your streak for a bigger fictional score.

**Design target:** A polished, mobile-friendly 2D luck game with quick rounds, satisfying reveals, readable odds, and a strong fantasy identity. The concept is designed to feel fresh, but no one can guarantee that no similar mechanic or title exists elsewhere; do a store and trademark search before release.

### Core loop

1. The player starts a run with a score of `0` and a short sequence of rounds.
2. Three gates appear: **Ember**, **Tide**, and **Gale**. Their artwork differs, but the outcome is selected by the game’s random outcome system—not by the visual design.
3. The player chooses one gate.
4. A reveal animation shows one of the possible outcomes: a score boost, a streak shield, a small bonus, or a run-ending “Void” result.
5. After a successful reveal, the player may **Bank Run Score** or **Continue**. Banking ends the run and saves the score locally. Continuing starts the next round with a stronger score multiplier and a rising chance of a Void result.
6. A Void ends the current run and resets the unbanked run score to `0`; it never takes purchased or redeemable assets because those do not exist.
7. The player earns a non-transferable personal best and cosmetic milestones only through play.

### MVP scope

- Offline, single-player game.
- Landscape and portrait layouts that adapt cleanly to phone and desktop screens.
- Three selectable gates and four result types.
- 7-round run, score multiplier, streak counter, and personal-best record.
- Short tutorial, settings, pause, sound toggle, reduced-motion option, and clear end-of-run screen.
- Local save data only.
- No login, backend, multiplayer, ads, analytics SDK, in-app purchases, real-money systems, or external links in the MVP.

### Explicit non-goals

- No cash or cash-equivalent prizes.
- No user-to-user transfers or tradable balances.
- No buying virtual coins, buying extra chances, or paid entries.
- No claims that the player can earn money.
- No manipulative “near miss” effects that misrepresent the actual random outcome.
- No geo-evasion, disguised gambling features, or attempts to bypass laws or app-store review.

---

## 2. Recommended technology

Use **Godot 4.x + GDScript** for the first build. Godot is a good fit for a compact 2D game because scenes, animation, input, UI, audio, and exporting are built in. Pin a specific stable Godot version in the project README after checking the version you install.

- Engine: Godot 4.x (2D renderer).
- Language: GDScript with static typing where practical.
- Art: original vector-style or pixel-art sprites; use placeholder shapes until the loop works.
- Audio: original or properly licensed short sound effects and loopable background music.
- Persistence: local config/save file using Godot’s `FileAccess` or `ConfigFile`.
- Source control: Git; commit after every milestone.
- Initial distribution: private desktop build and browser/demo build if supported by the chosen export setup. Review current export and platform constraints before choosing the final target.

**Do not start with a backend.** The MVP does not need user accounts, payments, cloud inventory, or a server. If online leaderboards are considered later, design and review them as a separate phase.

---

## 3. Player experience and UI

### Screens

1. **Title screen** — title logo, Play, How to Play, Settings, Credits.
2. **How to Play** — explain the round, possible outcomes, the rising risk, and Bank/Continue choices.
3. **Game screen** — score, round number, streak, multiplier, three gates, result panel, Bank Run Score, Continue.
4. **Reveal state** — temporarily disables gate inputs while the animation and result text play.
5. **Run-end screen** — final banked score or lost unbanked score, personal-best update, Play Again, Main Menu.
6. **Settings** — music/SFX toggles, reduced motion, high-contrast option if feasible.
7. **Credits & rules** — asset credits, fictional-score notice, privacy note, and support contact placeholder to be completed before public release.

### Visual direction

- Theme: floating ruins under an indigo night sky, glowing gates, drifting stars, and an ancient compass.
- Palette: deep navy background, warm amber, aqua, and pale violet accents. Keep text contrast high.
- Shapes: large rounded gate buttons with clear focus/pressed/disabled states.
- Animation: gate hover/pulse, a short reveal flash, particles for bonuses, and a calm fade on run end.
- Avoid slot-machine imagery, roulette wheels, piles of currency, casino tables, or money-focused marketing. The art direction should read as fantasy arcade, not a cash-gambling product.
- Never make a losing option look more or less likely than it really is unless the odds are explicitly changed and disclosed.

### Accessibility and usability

- All interactive elements need clear focus and pressed states.
- Do not use colour alone to communicate an outcome; add icons and text.
- Provide reduced-motion and sound toggles.
- Avoid rapid flashing and excessively loud audio.
- Support mouse, touchscreen, and keyboard selection.
- Keep important score and outcome text legible on small screens.

---

## 4. Game rules and chance model

Treat the values below as **initial tuning values**, not a promise of fairness or a final balancing result. Put them in one configuration resource rather than scattering magic numbers through scripts.

### Initial outcome table

| Outcome | Initial probability | Effect |
|---|---:|---|
| Starfall | 45% | Add the configured round reward to the run score |
| Lucky Echo | 25% | Add a smaller reward and increase the streak |
| Guardian Sigil | 15% | Give one shield that prevents the next Void from ending the run |
| Void | 15% | If no shield is available, end the run and clear its unbanked score; otherwise consume the shield and continue |

Probabilities must sum to exactly `100%` (or `1.0` in code). Show the possible outcomes and current rules in the How to Play screen. If probabilities are later changed by round, display that the risk changes and make the change explicit.

### Example scoring

- `base_reward = 100`
- `round_reward = base_reward * current_multiplier`
- Increase multiplier only after the result is resolved.
- Example multipliers: rounds 1–2: `1.0x`; rounds 3–4: `1.25x`; rounds 5–6: `1.5x`; round 7: `2.0x`.
- A shield can block one Void outcome. A blocked Void must be clearly announced, consume the shield, and must not also apply another outcome.
- Personal best is a score record, not an asset and not redeemable.

### RNG design rules

- Put random outcome selection in one isolated `OutcomeService`/script.
- Use the engine’s normal random generator for offline gameplay; initialise it once at session start or let the engine manage it. Do not reseed on every click.
- Do not choose outcomes based on the player’s previous wins/losses, session length, purchases, or any inferred vulnerability.
- Do not rig an outcome after showing the gate animation. Select the outcome first, then animate that result.
- Add a developer-only test mode that can force each outcome and set a deterministic seed. Keep test mode out of release exports.
- The MVP is not a cryptographically provable-fair online casino; do not claim that it is.

---

## 5. Proposed project structure

Use a clear, scene-based structure similar to this:

```text
luckbound-seven-gates/
├── project.godot
├── README.md
├── LICENSES.md
├── CHANGELOG.md
├── assets/
│   ├── art/
│   │   ├── backgrounds/
│   │   ├── gates/
│   │   ├── icons/
│   │   └── effects/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
├── scenes/
│   ├── main_menu.tscn
│   ├── game.tscn
│   ├── gate.tscn
│   ├── result_reveal.tscn
│   ├── run_end.tscn
│   ├── how_to_play.tscn
│   └── settings.tscn
├── scripts/
│   ├── app.gd
│   ├── game_controller.gd
│   ├── gate_controller.gd
│   ├── outcome_service.gd
│   ├── scoring_service.gd
│   ├── save_service.gd
│   ├── audio_service.gd
│   └── settings_service.gd
├── resources/
│   ├── outcome_table.tres
│   └── game_config.tres
└── tests_or_debug/
    └── rng_test_runner.gd
```

This is a target structure, not a requirement to create empty files. Add files only when they have a clear responsibility.

### Separation of responsibilities

- `game_controller.gd`: game state transitions and round flow.
- `gate_controller.gd`: gate input and visual state only; it must not decide outcomes.
- `outcome_service.gd`: chooses an outcome from the configured probability table.
- `scoring_service.gd`: score, multipliers, streaks, and shield rules.
- `save_service.gd`: validates and persists personal best/settings locally.
- `audio_service.gd`: sound/music playback and settings.
- UI scenes: display state and send user actions to the controller; do not duplicate game rules.

---

## 6. Build plan: milestone by milestone

### Milestone 0 — Validate the idea

- [ ] Check that the title is not already in use in game stores, search engines, and trademark databases.
- [ ] Write a one-page concept and a simple hand-drawn screen layout.
- [ ] Decide the first release target (desktop/web prototype first is recommended).
- [ ] Keep the MVP virtual-score-only and offline.
- **Exit condition:** You can explain the loop in one minute and the UI fits on a phone screen.

### Milestone 1 — Create the playable skeleton

- [ ] Create a Godot project and set display orientation/aspect behavior.
- [ ] Create the title screen and game screen with placeholder shapes.
- [ ] Add the three gate buttons and visible score/round labels.
- [ ] Add a state machine: `MENU`, `READY`, `REVEALING`, `DECISION`, `RUN_ENDED`.
- [ ] Ensure inputs are disabled while the game is resolving an outcome.
- **Exit condition:** The user can start a run, select a gate, see a result, and finish/restart without errors.

### Milestone 2 — Implement rules and testable randomness

- [ ] Implement the isolated outcome selector using configured weights.
- [ ] Validate weights when loading configuration; reject invalid or zero-total weights with a clear error.
- [ ] Implement score, streak, multiplier, shield, bank, continue, and Void behavior.
- [ ] Add debug controls or a test runner that can force all outcomes.
- [ ] Test each outcome at least 100 times in deterministic test mode; test the probability distribution over a much larger simulation for sanity (statistical results will vary).
- **Exit condition:** Rules work without requiring animations or art.

### Milestone 3 — Add feel and visual polish

- [ ] Create original gate sprites and background layers.
- [ ] Add reveal and transition animations with clear timing.
- [ ] Add sound cues for selection, reward, shield, Void, bank, and run end.
- [ ] Add particles sparingly; respect reduced-motion setting.
- [ ] Keep the outcome visible in text after each reveal.
- **Exit condition:** Every result is understandable even if animations and sound are disabled.

### Milestone 4 — Persistence and settings

- [ ] Save personal best and settings locally.
- [ ] Handle missing, malformed, or outdated save data by using safe defaults.
- [ ] Do not store payment, identity, precise location, or sensitive personal data.
- [ ] Add sound and reduced-motion settings.
- **Exit condition:** Restarting the game preserves the personal best and settings; corrupted save data does not crash the game.

### Milestone 5 — QA and balance

- [ ] Test with mouse, touchscreen, and keyboard.
- [ ] Test small and large aspect ratios, window resize, and full-screen mode.
- [ ] Check long labels, button hit areas, focus navigation, and contrast.
- [ ] Play at least 30 full runs and note confusing moments or boring downtime.
- [ ] Run an automated simulation to inspect score distribution and average run length; use results for tuning without changing outcomes covertly during a player session.
- [ ] Check performance on a low-end target device if Android is a target.
- **Exit condition:** No critical crashes, stuck states, double selections, or score discrepancies.

### Milestone 6 — Release gate

- [ ] Confirm all art, fonts, music, and SFX are original or licensed for the exact release use.
- [ ] Add complete credits and privacy disclosures appropriate to actual functionality.
- [ ] Produce versioned builds and a short changelog.
- [ ] Verify legal classification and all platform-specific policies for every intended country and distribution channel before publication.
- [ ] Do not use a different country setting, sideloading flow, misleading listing, or technical workaround to evade a legal or platform restriction.
- **Exit condition:** A documented review approves the actual shipped game and its distribution plan.

---

## 7. Important implementation details

### Game-state rules

- A gate can only be selected in `READY` or the active selection state.
- On selection, immediately disable all gates, set state to `REVEALING`, select one outcome exactly once, then animate that already-selected result.
- After reveal, move to `DECISION` if the run continues; otherwise move to `RUN_ENDED`.
- `Bank Run Score` is only available when a valid bank/decision is offered. It ends the run and commits the run score to the personal-best comparison.
- `Continue` advances the round and updates multiplier/risk configuration before the next selection.
- Prevent double clicks and race conditions by ignoring input during animations and transitions.
- Centralise state transitions; do not let individual gate scenes mutate global score.

### Save-data rules

- Save only personal-best score, sound settings, reduced-motion preference, and a save schema version.
- Clamp invalid numbers and fall back to defaults on parse errors.
- Avoid remote storage in the MVP.

### Error handling

- Missing assets should produce a visible development warning and use a safe placeholder where possible.
- A missing or invalid outcome table should fail safely rather than silently making an outcome always win or always lose.
- Add a debug overlay for FPS, current state, selected outcome, seed/test mode, and round; disable it in release builds.

---

## 8. Definition of done

The MVP is done when:

- The game can launch, start, play, bank/continue, end, and restart.
- All rules match this document and all four outcomes are testable.
- The chance table is configurable, valid, and documented.
- The personal best and settings persist locally and corrupted saves fail safely.
- The game is usable on a small touch screen and with keyboard/mouse.
- Sound, animation, and reduced-motion settings work.
- No real-money, purchaseable chance, cash-equivalent reward, or transfer feature exists in code, UI, remote services, or marketing.
- No third-party assets are included without verified rights and attribution where required.
- The README explains how to open, run, test, and export the project.
- Distribution is not started until legal and platform review is complete.

---

## 9. Suggested README commands and developer notes

Document the exact installed Godot version and the actual export workflow used. Do not invent shell commands for unsupported targets. Include:

- Project prerequisites and engine version.
- How to open `project.godot` in Godot.
- How to launch the main scene.
- How to run the RNG/rule test harness.
- How to enable test-only deterministic outcomes.
- Where to change probability and score settings.
- How to export the tested target.
- A list of known limitations and third-party asset licences.

---

## 10. Copy/paste prompt for an AI coding agent

Use this prompt in your coding agent after placing this file in the repository as `LUCKBOUND_GAME_WORKFLOW.md`:

> Read `LUCKBOUND_GAME_WORKFLOW.md` completely before coding. Build **LUCKBOUND: The Seven Gates** as a polished 2D Godot 4.x game in GDScript. Follow the milestone sequence and acceptance criteria in that file. Start with Milestone 1 and implement a genuinely runnable vertical slice; do not create a large set of empty placeholder files. Use clean, small scripts with clear ownership of game state, outcome selection, scoring, persistence, and UI. Keep all outcome weights in one configuration resource and select the outcome exactly once before revealing it. Build deterministic test mode for rules and random outcome simulations, but make sure test controls cannot be enabled in release builds. Use temporary original-looking placeholder graphics until the main loop works, then polish the interface. Add useful comments only where they clarify non-obvious logic. After each milestone, run the available checks, fix errors, and summarize changed files, how to run the game, tests performed, and remaining issues. Do not add network services, ads, analytics, login, payments, real-money bets, cash-outs, tradable currency, or prizes of real-world value. Do not implement methods to evade country laws or platform restrictions. If a request conflicts with this workflow, stop and explain the conflict instead of silently changing the scope.

---

## 11. Legal and platform review — required before public release

This document is a game-development plan, not legal advice. Rules change and classification depends on the actual features and business model.

As of this document’s date (22 October 2026), India’s official government information says the Promotion and Regulation of Online Gaming Act, 2025 prohibits online money games, including games of chance, skill, or a mixture; the 2026 Rules are stated to come into force on 1 May 2026. Do not infer that a virtual-score-only game is automatically approved; check the precise legal classification and any applicable registration or safety requirements with qualified Indian counsel and the relevant authority before release.

Google Play’s official real-money gambling policy says gambling apps are allowed only under its eligibility, licensing, application, location, age-gating, and other requirements. Check the latest full Developer Program Policy at release time; platform rules may change and separate policies can apply to simulated gambling, ads, age ratings, and monetisation. Do not interpret this brief as approval for Play Store publication.

Official references:

- Government of India / PIB, *Government Enacts Online Gaming Act 2025, Prohibits All Forms of Online Money Games* (18 March 2026): https://www.pib.gov.in/PressReleasePage.aspx?PRID=2241804&lang=2&reg=48
- Government of India / MeitY, *Promotion and Regulation of Online Gaming Rules, 2026* (22 April 2026): https://www.pib.gov.in/PressReleasePage.aspx?PRID=2254606&lang=1&reg=3
- India Code, *The Promotion and Regulation of Online Gaming Act, 2025*: https://www.indiacode.nic.in/bitstream/123456789/22148/1/a2025-32.pdf
- Google Play, *Real money gambling, games and contests*: https://support.google.com/googleplay/android-developer/answer/9877032?hl=en-IN

---

## 12. Final recommendation

Finish the offline, fictional-score MVP first and test it as a desktop or browser prototype before deciding on mobile distribution. Make the unique value come from the visual theme, short run structure, transparent probabilities, shield mechanic, and excellent feedback—not from real-money wagering. Verify title originality and platform/legal eligibility independently before release.
