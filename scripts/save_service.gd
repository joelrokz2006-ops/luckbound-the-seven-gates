# save_service.gd
# Manages local persistence for personal best, statistics, and run records.
# Resilient to corrupted or missing save files with safe schema fallbacks.
class_name SaveService
extends RefCounted

const SAVE_FILE_PATH: String = "user://luckbound_save.json"
const CURRENT_SCHEMA_VERSION: int = 1

var personal_best: int = 0
var runs_played: int = 0
var runs_banked: int = 0
var highest_streak: int = 0
var total_score_banked: int = 0

func _init() -> void:
	load_data()

func get_default_data() -> Dictionary:
	return {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"personal_best": 0,
		"runs_played": 0,
		"runs_banked": 0,
		"highest_streak": 0,
		"total_score_banked": 0
	}

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		apply_data(get_default_data())
		return

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_warning("SaveService: Could not open save file. Falling back to defaults.")
		apply_data(get_default_data())
		return

	var json_str: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_str)
	if parse_result != OK or not (json.data is Dictionary):
		push_warning("SaveService: Malformed save file JSON. Resetting to safe defaults.")
		apply_data(get_default_data())
		return

	var data: Dictionary = json.data
	apply_data(data)

func apply_data(data: Dictionary) -> void:
	# Safe clamping and type verification
	personal_best = max(0, int(data.get("personal_best", 0)))
	runs_played = max(0, int(data.get("runs_played", 0)))
	runs_banked = max(0, int(data.get("runs_banked", 0)))
	highest_streak = max(0, int(data.get("highest_streak", 0)))
	total_score_banked = max(0, int(data.get("total_score_banked", 0)))

func save_data() -> bool:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveService: Failed to open %s for writing!" % SAVE_FILE_PATH)
		return false

	var dict: Dictionary = {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"personal_best": personal_best,
		"runs_played": runs_played,
		"runs_banked": runs_banked,
		"highest_streak": highest_streak,
		"total_score_banked": total_score_banked
	}

	var json_str: String = JSON.stringify(dict, "\t")
	file.store_string(json_str)
	file.close()
	return true

# Updates personal best if new_score exceeds current record. Returns true if new record set.
func record_run_result(score: int, streak: int, is_banked: bool) -> bool:
	runs_played += 1
	var is_new_record: bool = false

	if is_banked:
		runs_banked += 1
		total_score_banked += score
		if score > personal_best:
			personal_best = score
			is_new_record = true

	if streak > highest_streak:
		highest_streak = streak

	save_data()
	return is_new_record

func reset_all_data() -> void:
	apply_data(get_default_data())
	save_data()
