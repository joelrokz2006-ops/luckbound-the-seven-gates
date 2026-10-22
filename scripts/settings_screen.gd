# settings_screen.gd
# Settings UI: audio toggles, volume sliders, reduced motion, high contrast, and data reset.
class_name SettingsScreen
extends Control

const SettingsService = preload("res://scripts/settings_service.gd")
const SaveService = preload("res://scripts/save_service.gd")

signal back_pressed

var settings: SettingsService
var save_service: SaveService

var check_music: CheckBox
var slider_music: HSlider
var check_sfx: CheckBox
var slider_sfx: HSlider
var check_reduced_motion: CheckBox
var check_high_contrast: CheckBox
var btn_reset_data: Button
var reset_confirm_dialog: ConfirmationDialog

func setup(p_settings: SettingsService, p_save_service: SaveService) -> void:
	settings = p_settings
	save_service = p_save_service
	_sync_ui_from_settings()

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	visible = false
	_build_ui()
	_sync_ui_from_settings()

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.03, 0.04, 0.1, 0.96)
	add_child(bg)

	var center: CenterContainer = CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 520)
	center.add_child(panel)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.18, 0.98)
	style.set_corner_radius_all(20)
	style.set_border_width_all(2)
	style.border_color = Color(0.35, 0.5, 0.85)
	style.content_margin_left = 36
	style.content_margin_right = 36
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	vbox.add_child(title)

	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 14)
	vbox.add_child(grid)

	# Music
	var lbl_music: Label = Label.new()
	lbl_music.text = "Ambient Music"
	grid.add_child(lbl_music)

	var h_music: HBoxContainer = HBoxContainer.new()
	check_music = CheckBox.new()
	check_music.text = "Enabled"
	check_music.toggled.connect(_on_music_toggled)
	h_music.add_child(check_music)

	slider_music = HSlider.new()
	slider_music.min_value = 0.0
	slider_music.max_value = 1.0
	slider_music.step = 0.05
	slider_music.custom_minimum_size = Vector2(160, 24)
	slider_music.value_changed.connect(_on_music_volume_changed)
	h_music.add_child(slider_music)
	grid.add_child(h_music)

	# SFX
	var lbl_sfx: Label = Label.new()
	lbl_sfx.text = "Sound Effects"
	grid.add_child(lbl_sfx)

	var h_sfx: HBoxContainer = HBoxContainer.new()
	check_sfx = CheckBox.new()
	check_sfx.text = "Enabled"
	check_sfx.toggled.connect(_on_sfx_toggled)
	h_sfx.add_child(check_sfx)

	slider_sfx = HSlider.new()
	slider_sfx.min_value = 0.0
	slider_sfx.max_value = 1.0
	slider_sfx.step = 0.05
	slider_sfx.custom_minimum_size = Vector2(160, 24)
	slider_sfx.value_changed.connect(_on_sfx_volume_changed)
	h_sfx.add_child(slider_sfx)
	grid.add_child(h_sfx)

	# Reduced Motion
	var lbl_motion: Label = Label.new()
	lbl_motion.text = "Reduced Motion"
	grid.add_child(lbl_motion)

	check_reduced_motion = CheckBox.new()
	check_reduced_motion.text = "Minimize screen shake & fast particles"
	check_reduced_motion.toggled.connect(_on_reduced_motion_toggled)
	grid.add_child(check_reduced_motion)

	# High Contrast
	var lbl_contrast: Label = Label.new()
	lbl_contrast.text = "High Contrast Mode"
	grid.add_child(lbl_contrast)

	check_high_contrast = CheckBox.new()
	check_high_contrast.text = "Enhance borders & text readability"
	check_high_contrast.toggled.connect(_on_high_contrast_toggled)
	grid.add_child(check_high_contrast)

	# Data reset
	var lbl_reset: Label = Label.new()
	lbl_reset.text = "Local Save Data"
	grid.add_child(lbl_reset)

	btn_reset_data = Button.new()
	btn_reset_data.text = "Reset Career Records"
	btn_reset_data.custom_minimum_size = Vector2(200, 36)
	btn_reset_data.pressed.connect(_on_reset_pressed)
	grid.add_child(btn_reset_data)

	# Reset Confirmation Dialog
	reset_confirm_dialog = ConfirmationDialog.new()
	reset_confirm_dialog.dialog_text = "Are you sure you want to reset your personal best and play statistics? This cannot be undone."
	reset_confirm_dialog.confirmed.connect(_on_reset_confirmed)
	add_child(reset_confirm_dialog)

	# Back button
	var btn_back: Button = Button.new()
	btn_back.text = "Save & Back (Esc)"
	btn_back.custom_minimum_size = Vector2(180, 44)
	btn_back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var b_style: StyleBoxFlat = StyleBoxFlat.new()
	b_style.bg_color = Color(0.2, 0.45, 0.8)
	b_style.set_corner_radius_all(10)
	btn_back.add_theme_stylebox_override("normal", b_style)
	btn_back.pressed.connect(func(): back_pressed.emit())
	vbox.add_child(btn_back)

func _sync_ui_from_settings() -> void:
	if not settings or not is_inside_tree() or not check_music:
		return
	check_music.button_pressed = settings.music_enabled
	slider_music.value = settings.music_volume
	check_sfx.button_pressed = settings.sfx_enabled
	slider_sfx.value = settings.sfx_volume
	check_reduced_motion.button_pressed = settings.reduced_motion
	check_high_contrast.button_pressed = settings.high_contrast

func _on_music_toggled(pressed: bool) -> void:
	if settings:
		settings.music_enabled = pressed
		settings.save_settings()

func _on_music_volume_changed(val: float) -> void:
	if settings:
		settings.music_volume = val
		settings.save_settings()

func _on_sfx_toggled(pressed: bool) -> void:
	if settings:
		settings.sfx_enabled = pressed
		settings.save_settings()

func _on_sfx_volume_changed(val: float) -> void:
	if settings:
		settings.sfx_volume = val
		settings.save_settings()

func _on_reduced_motion_toggled(pressed: bool) -> void:
	if settings:
		settings.reduced_motion = pressed
		settings.save_settings()

func _on_high_contrast_toggled(pressed: bool) -> void:
	if settings:
		settings.high_contrast = pressed
		settings.save_settings()

func _on_reset_pressed() -> void:
	reset_confirm_dialog.popup_centered()

func _on_reset_confirmed() -> void:
	if save_service:
		save_service.reset_all_data()
