# result_reveal.gd
# Visual animation for fate reveal: compass spin, elemental burst, score ticker, shield shield-crack.
class_name ResultReveal
extends Control

const OutcomeService = preload("res://scripts/outcome_service.gd")

signal reveal_animation_finished
signal continue_pressed
signal bank_pressed
signal view_summary_pressed

var outcome_data: Dictionary = {}
var animation_t: float = 0.0
var is_animating: bool = false
var show_decision_buttons: bool = false
var reduced_motion: bool = false

var compass_angle: float = 0.0
var flash_intensity: float = 0.0
var badge_scale: float = 0.0
var particles: Array[Dictionary] = []

# UI references
var panel_container: PanelContainer
var title_label: Label
var subtitle_label: Label
var detail_label: Label
var btn_continue: Button
var btn_bank: Button
var btn_summary: Button
var buttons_container: HBoxContainer

func _ready() -> void:
	custom_minimum_size = Vector2(500, 320)
	visible = false
	_build_ui()

func _build_ui() -> void:
	# Translucent dark backdrop
	anchor_right = 1.0
	anchor_bottom = 1.0

	var center_box: CenterContainer = CenterContainer.new()
	center_box.name = "CenterBox"
	center_box.anchor_right = 1.0
	center_box.anchor_bottom = 1.0
	add_child(center_box)

	var card: PanelContainer = PanelContainer.new()
	card.name = "RevealCard"
	card.custom_minimum_size = Vector2(540, 360)
	center_box.add_child(card)

	# Style card
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.14, 0.94)
	style.set_corner_radius_all(20)
	style.set_border_width_all(2)
	style.border_color = Color(0.3, 0.45, 0.75, 0.8)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.6)
	style.shadow_size = 20
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	card.add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	card.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "FATE REVEALED"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	vbox.add_child(title_label)

	# Subtitle / Outcome Name
	subtitle_label = Label.new()
	subtitle_label.text = "Starfall"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 22)
	subtitle_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(subtitle_label)

	# Detail text
	detail_label = Label.new()
	detail_label.text = "+100 Score added to unbanked run!"
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 16)
	detail_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95))
	vbox.add_child(detail_label)

	# Spacer
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	# Buttons container
	buttons_container = HBoxContainer.new()
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_container.add_theme_constant_override("separation", 24)
	vbox.add_child(buttons_container)

	# Continue Button
	btn_continue = Button.new()
	btn_continue.text = "Continue to Next Gate (Space)"
	btn_continue.custom_minimum_size = Vector2(200, 48)
	_style_button(btn_continue, Color(0.15, 0.55, 0.9), Color(0.2, 0.7, 1.0))
	btn_continue.pressed.connect(func(): continue_pressed.emit())
	buttons_container.add_child(btn_continue)

	# Bank Button
	btn_bank = Button.new()
	btn_bank.text = "Bank Run Score (B)"
	btn_bank.custom_minimum_size = Vector2(180, 48)
	_style_button(btn_bank, Color(0.85, 0.6, 0.1), Color(1.0, 0.75, 0.2))
	btn_bank.pressed.connect(func(): bank_pressed.emit())
	buttons_container.add_child(btn_bank)

	# Run ended summary button
	btn_summary = Button.new()
	btn_summary.text = "View Run Summary"
	btn_summary.custom_minimum_size = Vector2(220, 48)
	_style_button(btn_summary, Color(0.8, 0.25, 0.35), Color(0.95, 0.35, 0.45))
	btn_summary.pressed.connect(func(): view_summary_pressed.emit())
	btn_summary.visible = false
	buttons_container.add_child(btn_summary)

func _style_button(btn: Button, bg_col: Color, border_col: Color) -> void:
	var norm: StyleBoxFlat = StyleBoxFlat.new()
	norm.bg_color = bg_col
	norm.set_corner_radius_all(10)
	norm.set_border_width_all(2)
	norm.border_color = border_col
	norm.content_margin_left = 16
	norm.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", norm)

	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = bg_col.lightened(0.2)
	hover.set_corner_radius_all(10)
	hover.set_border_width_all(2)
	hover.border_color = Color.WHITE
	hover.content_margin_left = 16
	hover.content_margin_right = 16
	btn.add_theme_stylebox_override("hover", hover)

func start_reveal(data: Dictionary, p_reduced_motion: bool = false) -> void:
	outcome_data = data
	reduced_motion = p_reduced_motion
	visible = true
	is_animating = true
	animation_t = 0.0
	flash_intensity = 1.0 if not reduced_motion else 0.4
	badge_scale = 0.1

	buttons_container.visible = false
	btn_continue.visible = false
	btn_bank.visible = false
	btn_summary.visible = false

	# Configure text
	var outcome: int = data.get("outcome", 0)
	subtitle_label.text = data.get("outcome_name", "Revealed")
	detail_label.text = data.get("message", "")

	match outcome:
		OutcomeService.OutcomeType.STARFALL:
			title_label.text = "CELESTIAL BLESSING"
			title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			subtitle_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
		OutcomeService.OutcomeType.LUCKY_ECHO:
			title_label.text = "HARMONIC RESONANCE"
			title_label.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0))
			subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.95, 1.0))
		OutcomeService.OutcomeType.GUARDIAN_SIGIL:
			title_label.text = "AEGIS OF WARDING"
			title_label.add_theme_color_override("font_color", Color(0.3, 0.95, 0.65))
			subtitle_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.85))
		OutcomeService.OutcomeType.VOID:
			if data.get("shield_consumed", false):
				title_label.text = "SHIELD DEFLECTED THE VOID!"
				title_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
				subtitle_label.add_theme_color_override("font_color", Color(0.3, 0.95, 0.7))
			else:
				title_label.text = "THE VOID CONSUMES"
				title_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.4))
				subtitle_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.9))

	# Spawn visual particles
	particles.clear()
	if not reduced_motion:
		for i in range(24):
			var ang: float = randf() * TAU
			var spd: float = randf_range(80, 220)
			particles.append({
				"pos": size * 0.5,
				"vel": Vector2(cos(ang), sin(ang)) * spd,
				"col": _get_outcome_color(outcome),
				"life": randf_range(0.5, 1.0),
				"size": randf_range(3.0, 6.0)
			})

func _get_outcome_color(outcome: int) -> Color:
	match outcome:
		OutcomeService.OutcomeType.STARFALL:
			return Color(1.0, 0.85, 0.3)
		OutcomeService.OutcomeType.LUCKY_ECHO:
			return Color(0.25, 0.85, 1.0)
		OutcomeService.OutcomeType.GUARDIAN_SIGIL:
			return Color(0.35, 0.95, 0.65)
		OutcomeService.OutcomeType.VOID:
			return Color(0.85, 0.35, 0.95)
		_:
			return Color.WHITE

func _process(delta: float) -> void:
	if not visible:
		return

	if is_animating:
		animation_t += delta
		var anim_duration: float = 0.5 if reduced_motion else 0.9
		flash_intensity = maxf(0.0, flash_intensity - delta * (3.0 if reduced_motion else 1.8))
		compass_angle += delta * (8.0 * (1.0 - clampf(animation_t / anim_duration, 0.0, 1.0)))

		if animation_t >= anim_duration:
			is_animating = false
			_show_decision()
			reveal_animation_finished.emit()

	# Update particles
	for p in particles:
		p["pos"] += p["vel"] * delta
		p["life"] -= delta * 1.2
		p["vel"] *= 0.96

	queue_redraw()

func _show_decision() -> void:
	buttons_container.visible = true
	var run_ended: bool = outcome_data.get("run_ended", false)
	var is_completed: bool = outcome_data.get("is_run_completed", false)

	if run_ended or is_completed:
		btn_continue.visible = false
		btn_bank.visible = false
		btn_summary.visible = true
		btn_summary.grab_focus()
	else:
		btn_continue.visible = true
		btn_bank.visible = true
		btn_summary.visible = false
		btn_continue.grab_focus()

func _draw() -> void:
	if not visible:
		return

	# Draw particles
	for p in particles:
		if p["life"] > 0.0:
			var c: Color = p["col"]
			c.a = clampf(p["life"], 0.0, 1.0)
			draw_circle(p["pos"], p["size"] * c.a, c)

	# Full-screen reveal flash overlay
	if flash_intensity > 0.01:
		var flash_col: Color = _get_outcome_color(outcome_data.get("outcome", 0))
		flash_col.a = flash_intensity * 0.25
		draw_rect(Rect2(Vector2.ZERO, size), flash_col)
