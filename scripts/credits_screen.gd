# credits_screen.gd
# Credits, fictional-score disclosures, and local privacy notice.
class_name CreditsScreen
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
	panel.custom_minimum_size = Vector2(740, 540)
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
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "CREDITS & LEGAL DISCLOSURES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	vbox.add_child(title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660, 380)
	vbox.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	_add_entry(content, "Game Title", "LUCKBOUND: The Seven Gates (v1.0.0)")
	_add_entry(content, "Game Design & Engineering", "Built following the LUCKBOUND Build Specification.")
	_add_entry(content, "Technology", "Godot Engine 4.3 (gl_compatibility 2D renderer) + GDScript.")
	_add_entry(content, "Audio & Music", "Original procedural mathematical synthesis (ProceduralAudio GDScript). No third-party royalty dependencies.")
	_add_entry(content, "Art & Visuals", "Original algorithmic vector and particle effects designed in Godot 2D.")
	
	_add_entry(content, "Strict Fictional-Score Safety Boundary",
		"This game uses FICTIONAL VIRTUAL SCORE ONLY.\n" +
		"• No real-money deposits, wagers, cash-outs, prizes, or gifts.\n" +
		"• No crypto/NFT assets, transferable tokens, or paid chance entries.\n" +
		"• No purchases of virtual coins or extra chances exist in this software.\n" +
		"• Any resemblance to chance mechanics is strictly for offline arcade fantasy entertainment.")

	_add_entry(content, "Privacy & Telemetry",
		"LUCKBOUND is 100% offline. It contains NO analytics SDKs, NO tracking pixels, NO ad networks, and NO external network requests. " +
		"All settings and high scores remain exclusively on your local device.")

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

func _add_entry(container: VBoxContainer, heading: String, body: String) -> void:
	var h: Label = Label.new()
	h.text = heading
	h.add_theme_font_size_override("font_size", 16)
	h.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	container.add_child(h)

	var b: Label = Label.new()
	b.text = body
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(640, 0)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95))
	container.add_child(b)
