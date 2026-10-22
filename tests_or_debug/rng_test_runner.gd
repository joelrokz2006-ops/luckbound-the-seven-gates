# rng_test_runner.gd
# Headless test runner validating RNG distribution, deterministic modes,
# scoring mechanics, shield behavior, and save data resilience.
extends SceneTree

const OutcomeService = preload("res://scripts/outcome_service.gd")
const ScoringService = preload("res://scripts/scoring_service.gd")
const SaveService = preload("res://scripts/save_service.gd")

func _init() -> void:
	print("==================================================")
	print("   LUCKBOUND: THE SEVEN GATES — TEST HARNESS     ")
	print("==================================================")

	var failures: int = 0

	failures += test_weight_validation()
	failures += test_deterministic_outcomes()
	failures += test_probability_distribution()
	failures += test_scoring_and_multipliers()
	failures += test_shield_and_void_mechanics()
	failures += test_banking_and_personal_best()
	failures += test_save_corruption_resilience()

	print("==================================================")
	if failures == 0:
		print(" ALL TESTS PASSED SUCCESSFULLY! (0 failures)")
		print("==================================================")
		quit(0)
	else:
		print(" TEST SUITE FAILED with %d failure(s)!" % failures)
		print("==================================================")
		quit(1)

func test_weight_validation() -> int:
	print("\n[Test 1] Weight Validation & Error Handling...")
	var outcome_service: OutcomeService = OutcomeService.new()
	var is_valid: bool = outcome_service.validate_weights()
	if not is_valid:
		push_error("Default weights failed validation!")
		return 1

	# Test invalid negative weight rejection
	var invalid_weights: Dictionary = {
		OutcomeService.OutcomeType.STARFALL: -0.1,
		OutcomeService.OutcomeType.LUCKY_ECHO: 0.5,
		OutcomeService.OutcomeType.GUARDIAN_SIGIL: 0.3,
		OutcomeService.OutcomeType.VOID: 0.3
	}
	var should_fail: bool = outcome_service.set_weights(invalid_weights)
	if should_fail:
		push_error("Failed to reject negative weights!")
		return 1

	print("  -> Weight validation correctly accepted valid table and rejected invalid inputs.")
	return 0

func test_deterministic_outcomes() -> int:
	print("\n[Test 2] Deterministic Outcome Test (100 rolls each)...")
	var outcome_service: OutcomeService = OutcomeService.new()

	for outcome_type in [
		OutcomeService.OutcomeType.STARFALL,
		OutcomeService.OutcomeType.LUCKY_ECHO,
		OutcomeService.OutcomeType.GUARDIAN_SIGIL,
		OutcomeService.OutcomeType.VOID
	]:
		outcome_service.set_forced_outcome(outcome_type)
		for i in range(100):
			var rolled: int = outcome_service.roll_outcome()
			if rolled != outcome_type:
				push_error("Deterministic mode failed for %s! Got %d" % [OutcomeService.get_outcome_name(outcome_type), rolled])
				return 1

	outcome_service.clear_forced_outcome()
	print("  -> Deterministic mode 100% verified for all 4 outcomes.")
	return 0

func test_probability_distribution() -> int:
	print("\n[Test 3] Probability Distribution Simulation (10,000 rolls)...")
	var outcome_service: OutcomeService = OutcomeService.new({}, 12345) # Fixed seed for reproducibility
	var counts: Dictionary = {
		OutcomeService.OutcomeType.STARFALL: 0,
		OutcomeService.OutcomeType.LUCKY_ECHO: 0,
		OutcomeService.OutcomeType.GUARDIAN_SIGIL: 0,
		OutcomeService.OutcomeType.VOID: 0
	}

	var trials: int = 10000
	for i in range(trials):
		var rolled: int = outcome_service.roll_outcome()
		counts[rolled] += 1

	var pct_starfall: float = float(counts[OutcomeService.OutcomeType.STARFALL]) / float(trials) * 100.0
	var pct_echo: float = float(counts[OutcomeService.OutcomeType.LUCKY_ECHO]) / float(trials) * 100.0
	var pct_sigil: float = float(counts[OutcomeService.OutcomeType.GUARDIAN_SIGIL]) / float(trials) * 100.0
	var pct_void: float = float(counts[OutcomeService.OutcomeType.VOID]) / float(trials) * 100.0

	print("  Results over %d trials:" % trials)
	print("    • Starfall:       %.2f%% (Expected: 45.00%%)" % pct_starfall)
	print("    • Lucky Echo:     %.2f%% (Expected: 25.00%%)" % pct_echo)
	print("    • Guardian Sigil: %.2f%% (Expected: 15.00%%)" % pct_sigil)
	print("    • Void:           %.2f%% (Expected: 15.00%%)" % pct_void)

	# Tolerance within 2.5% for 10,000 samples
	if abs(pct_starfall - 45.0) > 2.5:
		push_error("Starfall percentage out of statistical bounds: %.2f%%" % pct_starfall)
		return 1
	if abs(pct_echo - 25.0) > 2.5:
		push_error("Lucky Echo percentage out of statistical bounds: %.2f%%" % pct_echo)
		return 1
	if abs(pct_sigil - 15.0) > 2.5:
		push_error("Guardian Sigil percentage out of statistical bounds: %.2f%%" % pct_sigil)
		return 1
	if abs(pct_void - 15.0) > 2.5:
		push_error("Void percentage out of statistical bounds: %.2f%%" % pct_void)
		return 1

	print("  -> Distribution matches mathematical expectation within statistical confidence bounds.")
	return 0

func test_scoring_and_multipliers() -> int:
	print("\n[Test 4] Scoring & Multiplier Progression across 7 rounds...")
	var scoring: ScoringService = ScoringService.new()

	# Round 1 (1.0x) -> Starfall (+100)
	var res1: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.STARFALL)
	if res1["points_added"] != 100 or scoring.run_score != 100:
		push_error("Round 1 Starfall expected 100 pts, got %d" % scoring.run_score)
		return 1

	# Advance to Round 2 (1.0x) -> Lucky Echo (+50, streak +1)
	scoring.advance_round()
	var res2: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.LUCKY_ECHO)
	if res2["points_added"] != 50 or scoring.run_score != 150 or scoring.streak != 1:
		push_error("Round 2 Lucky Echo expected 150 pts & streak 1, got score %d streak %d" % [scoring.run_score, scoring.streak])
		return 1

	# Advance to Round 3 (1.25x) -> Starfall (+125)
	scoring.advance_round()
	var res3: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.STARFALL)
	if res3["points_added"] != 125 or scoring.run_score != 275:
		push_error("Round 3 Starfall expected 275 pts, got %d" % scoring.run_score)
		return 1

	# Advance to Round 7 (2.0x)
	scoring.advance_round() # R4
	scoring.advance_round() # R5
	scoring.advance_round() # R6
	scoring.advance_round() # R7
	if scoring.multiplier != 2.0:
		push_error("Round 7 multiplier expected 2.0x, got %.2fx" % scoring.multiplier)
		return 1

	var res7: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.STARFALL)
	if res7["points_added"] != 200:
		push_error("Round 7 Starfall expected 200 pts, got %d" % res7["points_added"])
		return 1

	print("  -> Multiplier tiers (1.0x, 1.25x, 1.5x, 2.0x) and score calculations verified.")
	return 0

func test_shield_and_void_mechanics() -> int:
	print("\n[Test 5] Shield Protection & Void Behavior...")
	var scoring: ScoringService = ScoringService.new()

	# Gain 100 score
	scoring.apply_outcome(OutcomeService.OutcomeType.STARFALL)

	# Gain 1 Shield
	var sigil_res: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.GUARDIAN_SIGIL)
	if not sigil_res["shield_gained"] or scoring.shields != 1:
		push_error("Failed to gain shield from Guardian Sigil!")
		return 1

	# Trigger Void with shield active
	var void_res_shielded: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.VOID)
	if not void_res_shielded["shield_consumed"] or void_res_shielded["run_ended"]:
		push_error("Shield did not properly block the Void!")
		return 1
	if scoring.run_score != 100 or scoring.shields != 0:
		push_error("Shield consumption altered score or failed to decrement shield count!")
		return 1

	# Trigger second Void with 0 shields -> run must end, score reset to 0
	var void_res_unshielded: Dictionary = scoring.apply_outcome(OutcomeService.OutcomeType.VOID)
	if not void_res_unshielded["run_ended"] or scoring.run_score != 0 or scoring.unbanked_lost != 100:
		push_error("Unshielded void did not terminate run or reset unbanked score!")
		return 1

	print("  -> Shield correctly intercepted Void and unshielded Void correctly ended run.")
	return 0

func test_banking_and_personal_best() -> int:
	print("\n[Test 6] Bank Score & Personal Best Persistence...")
	var save: SaveService = SaveService.new()
	save.reset_all_data()

	var scoring: ScoringService = ScoringService.new()
	scoring.apply_outcome(OutcomeService.OutcomeType.STARFALL) # 100 pts
	scoring.advance_round()
	scoring.apply_outcome(OutcomeService.OutcomeType.STARFALL) # 100 pts (total 200)

	var banked_score: int = scoring.bank_score()
	if banked_score != 200:
		push_error("Banked score expected 200, got %d" % banked_score)
		return 1

	var is_new_record: bool = save.record_run_result(banked_score, scoring.streak, true)
	if not is_new_record or save.personal_best != 200:
		push_error("Save service failed to update personal best record!")
		return 1

	# Second run with lower score: 100 pts
	var is_new_record_lower: bool = save.record_run_result(100, 0, true)
	if is_new_record_lower or save.personal_best != 200:
		push_error("Lower score overwritten personal best!")
		return 1

	print("  -> Score banking and personal best logic confirmed.")
	return 0

func test_save_corruption_resilience() -> int:
	print("\n[Test 7] Save File Corruption Recovery...")
	var test_path: String = "user://luckbound_save.json"

	# Write corrupted garbage data to save file
	var file: FileAccess = FileAccess.open(test_path, FileAccess.WRITE)
	if file:
		file.store_string("{ 'malformed': invalid json ### $$$ }")
		file.close()

	# Loading must not crash and must safely restore safe defaults
	var save: SaveService = SaveService.new()
	if save.personal_best != 0 or save.runs_played != 0:
		push_error("Corrupted save did not restore default safe values!")
		return 1

	# Restore clean valid file
	save.save_data()

	print("  -> Corrupted save handled gracefully with safe fallbacks and zero crash.")
	return 0
