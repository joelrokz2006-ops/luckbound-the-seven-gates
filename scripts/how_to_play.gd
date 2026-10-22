# how_to_play.gd
# Explains the 7-round luck mechanics, transparent outcome probabilities, and shield rules.
class_name HowToPlay
extends Control

signal back_pressed

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	visible = false
	_build_ui()

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
	panel.custom_minimum_size = Vector2(760, 560)
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
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "HOW TO PLAY — THE SEVEN GATES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	vbox.add_child(title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 400)
	vbox.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

	_add_section(content, "1. The 7-Round Journey",
		"In each round, 3 gates appear before you: Ember (Flame), Tide (Water), and Gale (Wind).\n" +
		"Choose one gate (Click or press Keys 1, 2, or 3) to reveal your fate. Each gate has equal hidden odds.")

	_add_section(content, "2. Transparent Fate Probabilities",
		"✦ Starfall (45%): Grants the standard round reward (100 pts x Multiplier).\n" +
		"✦ Lucky Echo (25%): Grants a bonus reward (50 pts x Multiplier) and increases your Streak counter (+1).\n" +
		"✦ Guardian Sigil (15%): Grants 1 protective shield that guards your unbanked score from the next Void.\n" +
		"✦ Void (15%): If you possess a Shield, the shield shatters to protect your score! If you have no shield, your unbanked score resets to 0 and the run ends.")

	_add_section(content, "3. Rising Stakes & Multipliers",
		"As you venture deeper into the Seven Gates, the score multiplier rises:\n" +
		"• Gates 1–2: 1.0x Multiplier\n" +
		"• Gates 3–4: 1.25x Multiplier\n" +
		"• Gates 5–6: 1.5x Multiplier\n" +
		"• Gate 7: 2.0x Final Gate Multiplier!")

	_add_section(content, "4. Bank vs Continue",
		"After every surviving round, you must make a crucial choice:\n" +
		"• CONTINUE: Risk your unbanked points into the next round for greater multiplier rewards.\n" +
		"• BANK RUN SCORE: End the run voluntarily and secure all points to your local Personal Best record.")

	_add_section(content, "5. Fictional Score & Fair Play Boundary",
		"LUCKBOUND is an offline arcade game using fictional virtual score only.\n" +
		"There are NO real-money deposits, withdrawals, cash prizes, crypto, or in-app purchases.\n" +
		"Outcomes are determined cleanly and independently at the moment of selection.")

	var btn_back: Button = Button.new()
	btn_back.text = "Back to Menu (Esc)"
	btn_back.custom_minimum_size = Vector2(180, 44)
	btn_back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var b_style: StyleBoxFlat = StyleBoxFlat.new()
	b_style.bg_color = Color(0.2, 0.45, 0.8)
	b_style.set_corner_radius_all(10)
	btn_back.add_theme_stylebox_override("normal", b_style)
	btn_back.pressed.connect(func(): back_pressed.emit())
	vbox.add_child(btn_back)

func _add_section(container: VBoxContainer, header_text: String, body_text: String) -> void:
	var h: Label = Label.new()
	h.text = header_text
	h.add_theme_font_size_override("font_size", 17)
	h.add_theme_color_override("font_color", Color(0.35, 0.85, 1.0))
	container.add_child(h)

	var b: Label = Label.new()
	b.text = body_text
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(660, 0)
	b.add_theme_font_size_override("font_size", 14)
	b.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	container.add_child(b)
