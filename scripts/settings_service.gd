# settings_service.gd
# Manages user settings: audio volumes, reduced-motion, high contrast.
class_name SettingsService
extends RefCounted

signal settings_changed

const SETTINGS_FILE_PATH: String = "user://luckbound_settings.json"

var music_enabled: bool = true
var sfx_enabled: bool = true
var music_volume: float = 0.75
var sfx_volume: float = 0.85
var reduced_motion: bool = false
var high_contrast: bool = false

func _init() -> void:
	load_settings()

func get_default_settings() -> Dictionary:
	return {
		"music_enabled": true,
		"sfx_enabled": true,
		"music_volume": 0.75,
		"sfx_volume": 0.85,
		"reduced_motion": false,
		"high_contrast": false
	}

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		apply_settings(get_default_settings())
		return

	var file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if not file:
		apply_settings(get_default_settings())
		return

	var json_str: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	if json.parse(json_str) != OK or not (json.data is Dictionary):
		apply_settings(get_default_settings())
		return

	apply_settings(json.data)

func apply_settings(data: Dictionary) -> void:
	music_enabled = bool(data.get("music_enabled", true))
	sfx_enabled = bool(data.get("sfx_enabled", true))
	music_volume = clampf(float(data.get("music_volume", 0.75)), 0.0, 1.0)
	sfx_volume = clampf(float(data.get("sfx_volume", 0.85)), 0.0, 1.0)
	reduced_motion = bool(data.get("reduced_motion", false))
	high_contrast = bool(data.get("high_contrast", false))
	settings_changed.emit()

func save_settings() -> bool:
	var file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if not file:
		return false

	var dict: Dictionary = {
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"reduced_motion": reduced_motion,
		"high_contrast": high_contrast
	}

	file.store_string(JSON.stringify(dict, "\t"))
	file.close()
	settings_changed.emit()
	return true
