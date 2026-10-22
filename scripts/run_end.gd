# run_end.gd
# Displays final run statistics, personal-best updates, and options to play again or return to menu.
class_name RunEnd
extends Control

signal play_again_pressed
signal main_menu_pressed

var panel: PanelContainer
var title_label: Label
var status_label: Label
var score_val_label: Label
var record_badge: Label
var stats_label: Label
var btn_again: Button
var btn_menu: Button

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	visible = false
	_build_ui()

func _build_ui() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 420)
	center.add_child(panel)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.13, 0.96)
	style.set_corner_radius_all(20)
	style.set_border_width_all(2)
	style.border_color = Color(0.35, 0.5, 0.85)
	style.shadow_size = 24
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.content_margin_left = 36
	style.content_margin_right = 36
	style.content_margin_top = 32
	style.content_margin_bottom = 32
	panel.add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	title_label = Label.new()
	title_label.text = "RUN CONCLUDED"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	vbox.add_child(title_label)

	status_label = Label.new()
	status_label.text = "Score Banked Successfully!"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(status_label)

	score_val_label = Label.new()
	score_val_label.text = "Final Banked Score: 1,450"
	score_val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_val_label.add_theme_font_size_override("font_size", 32)
	score_val_label.add_theme_color_override("font_color", Color(0.3, 0.95, 0.7))
	vbox.add_child(score_val_label)

	record_badge = Label.new()
	record_badge.text = "✦ NEW PERSONAL BEST! ✦"
	record_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	record_badge.add_theme_font_size_override("font_size", 16)
	record_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(record_badge)

	stats_label = Label.new()
	stats_label.text = "Rounds Survived: 7 / 7 | Best Streak: 4 | Personal Best: 1,450"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 15)
	stats_label.add_theme_color_override("font_color", Color(0.75, 0.8, 0.9))
	vbox.add_child(stats_label)

	# Fictional score reminder
	var disclaimer: Label = Label.new()
	disclaimer.text = "Fictional score only. No real money or cash value."
	disclaimer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	disclaimer.add_theme_font_size_override("font_size", 12)
	disclaimer.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	vbox.add_child(disclaimer)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 14)
	vbox.add_child(spacer)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)

	btn_again = Button.new()
	btn_again.text = "Play Again (Space)"
	btn_again.custom_minimum_size = Vector2(180, 46)
	_style_button(btn_again, Color(0.2, 0.6, 0.95))
	btn_again.pressed.connect(func(): play_again_pressed.emit())
	hbox.add_child(btn_again)

	btn_menu = Button.new()
	btn_menu.text = "Main Menu"
	btn_menu.custom_minimum_size = Vector2(160, 46)
	_style_button(btn_menu, Color(0.25, 0.3, 0.45))
	btn_menu.pressed.connect(func(): main_menu_pressed.emit())
	hbox.add_child(btn_menu)

func _style_button(btn: Button, bg_col: Color) -> void:
	var norm: StyleBoxFlat = StyleBoxFlat.new()
	norm.bg_color = bg_col
	norm.set_corner_radius_all(10)
	norm.set_border_width_all(2)
	norm.border_color = bg_col.lightened(0.3)
	norm.content_margin_left = 16
	norm.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", norm)

	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = bg_col.lightened(0.2)
	hover.set_corner_radius_all(10)
	hover.set_border_width_all(2)
	hover.border_color = Color.WHITE
	btn.add_theme_stylebox_override("hover", hover)

func show_run_summary(
	is_banked: bool,
	final_score: int,
	unbanked_lost: int,
	rounds_survived: int,
	streak: int,
	is_new_best: bool,
	personal_best: int
) -> void:
	visible = true

	if is_banked:
		if rounds_survived >= 7:
			title_label.text = "SEVEN GATES CONQUERED!"
			title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
			status_label.text = "You cleared all Seven Gates and triumphed!"
			status_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.7))
		else:
			title_label.text = "RUN BANKED SAFELY"
			title_label.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
			status_label.text = "You chose to bank your run score!"
			status_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))

		score_val_label.text = "Banked Score: %d" % final_score
		score_val_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.7))
	else:
		title_label.text = "CONSUMED BY THE VOID"
		title_label.add_theme_color_override("font_color", Color(0.95, 0.35, 0.45))
		status_label.text = "The unbanked score was lost to the ether."
		status_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.65))
		score_val_label.text = "Lost: %d | Final Score: 0" % unbanked_lost
		score_val_label.add_theme_color_override("font_color", Color(0.95, 0.4, 0.45))

	record_badge.visible = is_new_best
	stats_label.text = "Rounds Survived: %d / 7  |  Best Streak: %d  |  Personal Best: %d" % [rounds_survived, streak, personal_best]
	btn_again.grab_focus()
