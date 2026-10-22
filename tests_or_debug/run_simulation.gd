# run_simulation.gd
# Simulates full player runs across various banking strategies to inspect
# score distributions, average run length, shield usage, and ensure no deadlocks.
extends SceneTree

const OutcomeService = preload("res://scripts/outcome_service.gd")
const ScoringService = preload("res://scripts/scoring_service.gd")
const SaveService = preload("res://scripts/save_service.gd")

func _init() -> void:
	print("\n==================================================")
	print("  LUCKBOUND: FULL GAMEPLAY RUN SIMULATION         ")
	print("==================================================")

	var num_runs: int = 100
	var total_rounds_survived: int = 0
	var banked_runs: int = 0
	var void_losses: int = 0
	var total_banked_score: int = 0
	var highest_score: int = 0
	var shields_consumed_total: int = 0

	var outcome_service: OutcomeService = OutcomeService.new()
	var scoring_service: ScoringService = ScoringService.new()
	var save_service: SaveService = SaveService.new()

	# Strategy: Player tries to reach at least Gate 4 before banking, or banks if score >= 350
	for r in range(num_runs):
		scoring_service.reset_run()
		var run_rounds: int = 0

		while scoring_service.run_active:
			run_rounds += 1
			var outcome: int = outcome_service.roll_outcome()
			var res: Dictionary = scoring_service.apply_outcome(outcome)

			if res.get("shield_consumed", false):
				shields_consumed_total += 1

			if res.get("run_ended", false):
				void_losses += 1
				break

			# Strategy decision after surviving:
			# If player reached Gate 7, they complete and auto-bank!
			if scoring_service.current_round >= 7:
				var banked: int = scoring_service.bank_score()
				banked_runs += 1
				total_banked_score += banked
				highest_score = maxi(highest_score, banked)
				save_service.record_run_result(banked, scoring_service.streak, true)
				break

			# If player has >= 350 points and Gate >= 4, bank score
			if scoring_service.run_score >= 350 and scoring_service.current_round >= 4:
				var banked: int = scoring_service.bank_score()
				banked_runs += 1
				total_banked_score += banked
				highest_score = maxi(highest_score, banked)
				save_service.record_run_result(banked, scoring_service.streak, true)
				break

			# Otherwise, continue to next round
			var could_advance: bool = scoring_service.advance_round()
			if not could_advance:
				break

		total_rounds_survived += run_rounds

	var avg_rounds: float = float(total_rounds_survived) / float(num_runs)
	var avg_banked: float = float(total_banked_score) / float(maxi(1, banked_runs))
	var win_rate: float = float(banked_runs) / float(num_runs) * 100.0

	print("Simulation Results for %d Complete Runs:" % num_runs)
	print("  • Average Gates Played per Run: %.2f" % avg_rounds)
	print("  • Successful Banked Runs:       %d (%.1f%%)" % [banked_runs, win_rate])
	print("  • Void Defeats:                 %d (%.1f%%)" % [void_losses, 100.0 - win_rate])
	print("  • Shields Deflected Voids:      %d times" % shields_consumed_total)
	print("  • Average Banked Score:         %.1f" % avg_banked)
	print("  • Peak Score Achieved:          %d" % highest_score)
	print("==================================================")
	print(" SIMULATION COMPLETED WITH NO CRASHES OR DEADLOCKS")
	print("==================================================\n")
	quit(0)
