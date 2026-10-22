# outcome_service.gd
# Isolated outcome selector for LUCKBOUND: The Seven Gates
# Selects an outcome based on configured weights. Never rigs outcomes.
class_name OutcomeService
extends RefCounted

enum OutcomeType {
	STARFALL = 0,
	LUCKY_ECHO = 1,
	GUARDIAN_SIGIL = 2,
	VOID = 3
}

const OUTCOME_NAMES: Dictionary = {
	OutcomeType.STARFALL: "Starfall",
	OutcomeType.LUCKY_ECHO: "Lucky Echo",
	OutcomeType.GUARDIAN_SIGIL: "Guardian Sigil",
	OutcomeType.VOID: "Void"
}

# Probabilities as percentages summing to 100.0 (or fractions summing to 1.0)
var weights: Dictionary = {
	OutcomeType.STARFALL: 0.45,
	OutcomeType.LUCKY_ECHO: 0.25,
	OutcomeType.GUARDIAN_SIGIL: 0.15,
	OutcomeType.VOID: 0.15
}

var rng: RandomNumberGenerator
var deterministic_forced_outcome: int = -1 # -1 means normal random roll

func _init(custom_weights: Dictionary = {}, initial_seed: int = -1) -> void:
	rng = RandomNumberGenerator.new()
	if initial_seed >= 0:
		rng.seed = initial_seed
	else:
		rng.randomize()
	
	if not custom_weights.is_empty():
		set_weights(custom_weights)
	else:
		validate_weights()

func validate_weights() -> bool:
	var total: float = 0.0
	for key in weights:
		var w: float = weights[key]
		if w < 0.0:
			push_error("OutcomeService: Weight cannot be negative for %s: %f" % [key, w])
			return false
		total += w
	
	# Allow minor floating point inaccuracy (e.g. 0.9999 to 1.0001)
	if abs(total - 1.0) > 0.001 and abs(total - 100.0) > 0.1:
		push_error("OutcomeService: Weights must sum to 1.0 or 100. Current sum: %f" % total)
		return false
	return true

func set_weights(new_weights: Dictionary) -> bool:
	var total: float = 0.0
	for key in new_weights:
		total += float(new_weights[key])
	
	if total <= 0.0:
		push_error("OutcomeService: Invalid total weight sum: %f" % total)
		return false
	
	# Normalize to 1.0 if entered as percentages
	var normalized: Dictionary = {}
	for key in new_weights:
		normalized[int(key)] = float(new_weights[key]) / total
	
	weights = normalized
	return validate_weights()

func roll_outcome() -> int:
	# If developer forced outcome is active (test mode only)
	if deterministic_forced_outcome >= 0 and deterministic_forced_outcome in weights:
		return deterministic_forced_outcome
	
	var rand_val: float = rng.randf()
	var cumulative: float = 0.0
	
	# Order check: Starfall, Lucky Echo, Guardian Sigil, Void
	var keys: Array = [OutcomeType.STARFALL, OutcomeType.LUCKY_ECHO, OutcomeType.GUARDIAN_SIGIL, OutcomeType.VOID]
	for outcome in keys:
		if outcome in weights:
			cumulative += weights[outcome]
			if rand_val <= cumulative:
				return outcome
				
	# Fallback in case of rounding edge
	return OutcomeType.STARFALL

func set_forced_outcome(outcome: int) -> void:
	deterministic_forced_outcome = outcome

func clear_forced_outcome() -> void:
	deterministic_forced_outcome = -1

func set_seed(new_seed: int) -> void:
	rng.seed = new_seed

static func get_outcome_name(outcome: int) -> String:
	return OUTCOME_NAMES.get(outcome, "Unknown")
