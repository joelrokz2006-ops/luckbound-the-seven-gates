# app.gd
# Root application coordinator initializing services, backgrounds, and scene transitions.
class_name App
extends Control

const SaveService = preload("res://scripts/save_service.gd")
const SettingsService = preload("res://scripts/settings_service.gd")
const AudioService = preload("res://scripts/audio_service.gd")
const OutcomeService = preload("res://scripts/outcome_service.gd")
const ScoringService = preload("res://scripts/scoring_service.gd")
const CelestialBackground = preload("res://scripts/celestial_background.gd")
const MainMenu = preload("res://scripts/main_menu.gd")
const GameController = preload("res://scripts/game_controller.gd")
const HowToPlay = preload("res://scripts/how_to_play.gd")
const SettingsScreen = preload("res://scripts/settings_screen.gd")
const CreditsScreen = preload("res://scripts/credits_screen.gd")

var save_service: SaveService
var settings_service: SettingsService
var audio_service: AudioService
var outcome_service: OutcomeService
var scoring_service: ScoringService

var celestial_bg: CelestialBackground
var main_menu: MainMenu
var game_controller: GameController
var how_to_play: HowToPlay
var settings_screen: SettingsScreen
var credits_screen: CreditsScreen

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	_initialize_services()
	_build_scene_graph()
	_connect_events()

	# Start background music and show main menu
	audio_service.play_music()
	show_main_menu()

func _initialize_services() -> void:
	save_service = SaveService.new()
	settings_service = SettingsService.new()
	outcome_service = OutcomeService.new()
	scoring_service = ScoringService.new()

	audio_service = AudioService.new()
	audio_service.name = "AudioService"
	add_child(audio_service)
	audio_service.setup_settings(settings_service)

func _build_scene_graph() -> void:
	# Persistent starry celestial background
	celestial_bg = CelestialBackground.new()
	celestial_bg.name = "CelestialBackground"
	add_child(celestial_bg)

	# Main menu screen
	main_menu = MainMenu.new()
	main_menu.name = "MainMenu"
	main_menu.setup(save_service)
	add_child(main_menu)

	# Main game screen
	game_controller = GameController.new()
	game_controller.name = "GameController"
	game_controller.setup_services(outcome_service, scoring_service, save_service, settings_service, audio_service)
	game_controller.visible = false
	add_child(game_controller)

	# How to Play overlay
	how_to_play = HowToPlay.new()
	how_to_play.name = "HowToPlay"
	how_to_play.visible = false
	add_child(how_to_play)

	# Settings screen overlay
	settings_screen = SettingsScreen.new()
	settings_screen.name = "SettingsScreen"
	settings_screen.setup(settings_service, save_service)
	settings_screen.visible = false
	add_child(settings_screen)

	# Credits & Rules screen overlay
	credits_screen = CreditsScreen.new()
	credits_screen.name = "CreditsScreen"
	credits_screen.visible = false
	add_child(credits_screen)

func _connect_events() -> void:
	main_menu.play_requested.connect(start_game)
	main_menu.how_to_play_requested.connect(show_how_to_play)
	main_menu.settings_requested.connect(show_settings)
	main_menu.credits_requested.connect(show_credits)

	game_controller.return_to_menu_requested.connect(show_main_menu)
	how_to_play.back_pressed.connect(show_main_menu)
	settings_screen.back_pressed.connect(show_main_menu)
	credits_screen.back_pressed.connect(show_main_menu)

	settings_service.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()

func show_main_menu() -> void:
	_hide_all_screens()
	main_menu.visible = true
	main_menu.update_best_score()
	if audio_service:
		audio_service.play_sfx("button_click")

func start_game() -> void:
	_hide_all_screens()
	game_controller.visible = true
	game_controller.start_new_run()
	if audio_service:
		audio_service.play_sfx("button_click")

func show_how_to_play() -> void:
	_hide_all_screens()
	how_to_play.visible = true
	if audio_service:
		audio_service.play_sfx("button_click")

func show_settings() -> void:
	_hide_all_screens()
	settings_screen.visible = true
	if audio_service:
		audio_service.play_sfx("button_click")

func show_credits() -> void:
	_hide_all_screens()
	credits_screen.visible = true
	if audio_service:
		audio_service.play_sfx("button_click")

func _hide_all_screens() -> void:
	main_menu.visible = false
	game_controller.visible = false
	how_to_play.visible = false
	settings_screen.visible = false
	credits_screen.visible = false

func _on_settings_changed() -> void:
	if celestial_bg:
		celestial_bg.reduced_motion = settings_service.reduced_motion
