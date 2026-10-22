# outcome_table_resource.gd
class_name OutcomeTableResource
extends Resource

@export var starfall_weight: float = 0.45
@export var lucky_echo_weight: float = 0.25
@export var guardian_sigil_weight: float = 0.15
@export var void_weight: float = 0.15

func get_weights_dict() -> Dictionary:
	return {
		OutcomeService.OutcomeType.STARFALL: starfall_weight,
		OutcomeService.OutcomeType.LUCKY_ECHO: lucky_echo_weight,
		OutcomeService.OutcomeType.GUARDIAN_SIGIL: guardian_sigil_weight,
		OutcomeService.OutcomeType.VOID: void_weight
	}
