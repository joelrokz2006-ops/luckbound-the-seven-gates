# scoring_service.gd
# Handles score calculation, streaks, multipliers, round advancement, and shield rules.
class_name ScoringService
extends RefCounted

const OutcomeService = preload("res://scripts/outcome_service.gd")

const MAX_ROUNDS: int = 7
const BASE_REWARD: int = 100
const ECHO_REWARD: int = 50

var current_round: int = 1
var run_score: int = 0
var streak: int = 0
var shields: int = 0
var multiplier: float = 1.0
var run_active: bool = false
var unbanked_lost: int = 0

func _init() -> void:
	reset_run()

func reset_run() -> void:
	current_round = 1
	run_score = 0
	streak = 0
	shields = 0
	multiplier = get_multiplier_for_round(1)
	run_active = true
	unbanked_lost = 0

func get_multiplier_for_round(round_num: int) -> float:
	match round_num:
		1, 2:
			return 1.0
		3, 4:
			return 1.25
		5, 6:
			return 1.5
		7:
			return 2.0
		_:
			return 2.0

func apply_outcome(outcome: int) -> Dictionary:
	var result: Dictionary = {
		"outcome": outcome,
		"outcome_name": OutcomeService.get_outcome_name(outcome),
		"points_added": 0,
		"streak_increased": false,
		"shield_gained": false,
		"shield_consumed": false,
		"run_ended": false,
		"is_void_defeat": false,
		"is_run_completed": false,
		"message": ""
	}

	match outcome:
		OutcomeService.OutcomeType.STARFALL:
			var points: int = int(round(BASE_REWARD * multiplier))
			run_score += points
			result["points_added"] = points
			result["message"] = "Starfall strikes! +%d Score" % points

		OutcomeService.OutcomeType.LUCKY_ECHO:
			var points: int = int(round(ECHO_REWARD * multiplier))
			run_score += points
			streak += 1
			result["points_added"] = points
			result["streak_increased"] = true
			result["message"] = "Lucky Echo resonated! +%d Score & Streak +1 (Streak: %d)" % [points, streak]

		OutcomeService.OutcomeType.GUARDIAN_SIGIL:
			shields += 1
			result["shield_gained"] = true
			result["message"] = "Guardian Sigil invoked! Gained 1 Protective Shield (Shields: %d)" % shields

		OutcomeService.OutcomeType.VOID:
			if shields > 0:
				shields -= 1
				result["shield_consumed"] = true
				result["message"] = "Guardian Shield shattered to block the Void! Your run was saved!"
			else:
				unbanked_lost = run_score
				run_score = 0
				streak = 0
				run_active = false
				result["run_ended"] = true
				result["is_void_defeat"] = true
				result["message"] = "The Void consumed the floating gate! Unbanked score was lost to the ether."

	return result

# Advances round and updates multiplier. Returns true if advanced, false if run max rounds reached.
func advance_round() -> bool:
	if current_round >= MAX_ROUNDS:
		# Player survived round 7!
		run_active = false
		return false
	
	current_round += 1
	multiplier = get_multiplier_for_round(current_round)
	return true

func bank_score() -> int:
	var final_score: int = run_score
	run_active = false
	return final_score
