# main_menu.gd
# Title screen with navigation to Play, How to Play, Settings, and Credits.
class_name MainMenu
extends Control

const SaveService = preload("res://scripts/save_service.gd")

signal play_requested
signal how_to_play_requested
signal settings_requested
signal credits_requested

var save_service: SaveService
var best_score_label: Label
var title_label: Label
var subtitle_label: Label
var btn_play: Button
var btn_how: Button
var btn_settings: Button
var btn_credits: Button

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	_build_ui()

func setup(p_save_service: SaveService) -> void:
	save_service = p_save_service
	update_best_score()

func update_best_score() -> void:
	if save_service and best_score_label:
		best_score_label.text = "Personal Best: %d  |  Runs Banked: %d" % [save_service.personal_best, save_service.runs_banked]

func _build_ui() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	# Title Banner
	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.alignment = BoxContainer.ALIGNMENT_CENTER
	title_box.add_theme_constant_override("separation", 6)
	vbox.add_child(title_box)

	title_label = Label.new()
	title_label.text = "LUCKBOUND"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	title_box.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "✦ THE SEVEN GATES ✦"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 20)
	subtitle_label.add_theme_color_override("font_color", Color(0.35, 0.85, 1.0))
	title_box.add_child(subtitle_label)

	var lore: Label = Label.new()
	lore.text = "Venture through the floating ruins. Choose your gate. Face your fortune."
	lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore.add_theme_font_size_override("font_size", 14)
	lore.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	title_box.add_child(lore)

	# Best score display
	best_score_label = Label.new()
	best_score_label.text = "Personal Best: 0  |  Runs Banked: 0"
	best_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_score_label.add_theme_font_size_override("font_size", 15)
	best_score_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.7))
	vbox.add_child(best_score_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Buttons
	var btn_box: VBoxContainer = VBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_box.add_theme_constant_override("separation", 14)
	vbox.add_child(btn_box)

	btn_play = Button.new()
	btn_play.text = "ENTER THE GATES"
	btn_play.custom_minimum_size = Vector2(260, 52)
	_style_menu_button(btn_play, Color(0.2, 0.55, 0.95), Color(0.4, 0.8, 1.0), 18)
	btn_play.pressed.connect(func(): play_requested.emit())
	btn_box.add_child(btn_play)

	btn_how = Button.new()
	btn_how.text = "How to Play"
	btn_how.custom_minimum_size = Vector2(260, 44)
	_style_menu_button(btn_how, Color(0.12, 0.16, 0.28), Color(0.3, 0.45, 0.7), 15)
	btn_how.pressed.connect(func(): how_to_play_requested.emit())
	btn_box.add_child(btn_how)

	btn_settings = Button.new()
	btn_settings.text = "Settings"
	btn_settings.custom_minimum_size = Vector2(260, 44)
	_style_menu_button(btn_settings, Color(0.12, 0.16, 0.28), Color(0.3, 0.45, 0.7), 15)
	btn_settings.pressed.connect(func(): settings_requested.emit())
	btn_box.add_child(btn_settings)

	btn_credits = Button.new()
	btn_credits.text = "Credits & Rules"
	btn_credits.custom_minimum_size = Vector2(260, 44)
	_style_menu_button(btn_credits, Color(0.12, 0.16, 0.28), Color(0.3, 0.45, 0.7), 15)
	btn_credits.pressed.connect(func(): credits_requested.emit())
	btn_box.add_child(btn_credits)

	# Footer note
	var footer: Label = Label.new()
	footer.text = "Fictional score only. No real money or wagers."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6))
	vbox.add_child(footer)

	btn_play.grab_focus()

func _style_menu_button(btn: Button, bg_col: Color, border_col: Color, font_size: int) -> void:
	var norm: StyleBoxFlat = StyleBoxFlat.new()
	norm.bg_color = bg_col
	norm.set_corner_radius_all(12)
	norm.set_border_width_all(2)
	norm.border_color = border_col
	norm.content_margin_left = 20
	norm.content_margin_right = 20
	btn.add_theme_stylebox_override("normal", norm)

	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = bg_col.lightened(0.2)
	hover.set_corner_radius_all(12)
	hover.set_border_width_all(2)
	hover.border_color = Color.WHITE
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", font_size)
