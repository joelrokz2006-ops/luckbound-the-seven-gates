# audio_service.gd
# Audio manager for sound effects and ambient celestial soundtrack.
class_name AudioService
extends Node

const SettingsService = preload("res://scripts/settings_service.gd")
const ProceduralAudio = preload("res://scripts/procedural_audio.gd")

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

var clips: Dictionary = {}
var settings: SettingsService

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)

	_generate_clips()

func setup_settings(p_settings: SettingsService) -> void:
	settings = p_settings
	settings.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()

func _generate_clips() -> void:
	clips["gate_hover"] = ProceduralAudio.generate_gate_hover()
	clips["gate_select"] = ProceduralAudio.generate_gate_select()
	clips["starfall"] = ProceduralAudio.generate_starfall()
	clips["lucky_echo"] = ProceduralAudio.generate_lucky_echo()
	clips["guardian_sigil"] = ProceduralAudio.generate_guardian_sigil()
	clips["void"] = ProceduralAudio.generate_void()
	clips["shield_block"] = ProceduralAudio.generate_shield_block()
	clips["bank"] = ProceduralAudio.generate_bank()
	clips["button_click"] = ProceduralAudio.generate_button_click()
	clips["ambient_loop"] = ProceduralAudio.generate_ambient_loop()

func play_sfx(clip_name: String) -> void:
	if settings and not settings.sfx_enabled:
		return
	if not clips.has(clip_name):
		return

	# Create a temporary one-shot player for polyphonic overlapping sounds
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.stream = clips[clip_name]
	var vol: float = settings.sfx_volume if settings else 0.85
	player.volume_db = linear_to_db(vol)
	player.finished.connect(player.queue_free)
	player.play()

func play_music() -> void:
	if settings and not settings.music_enabled:
		return
	if not clips.has("ambient_loop"):
		return
	if music_player.playing:
		return

	music_player.stream = clips["ambient_loop"]
	var vol: float = settings.music_volume if settings else 0.75
	music_player.volume_db = linear_to_db(vol)
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func _on_settings_changed() -> void:
	if not settings:
		return

	if not settings.music_enabled:
		music_player.stop()
	else:
		if not music_player.playing:
			play_music()
		music_player.volume_db = linear_to_db(settings.music_volume)

	sfx_player.volume_db = linear_to_db(settings.sfx_volume)
