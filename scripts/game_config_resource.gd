# game_config_resource.gd
class_name GameConfigResource
extends Resource

@export var max_rounds: int = 7
@export var base_reward: int = 100
@export var echo_reward: int = 50
@export var round_multipliers: Array[float] = [1.0, 1.0, 1.25, 1.25, 1.5, 1.5, 2.0]
