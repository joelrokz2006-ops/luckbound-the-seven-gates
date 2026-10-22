# gate_controller.gd
# Visual representation and input handling for a single Gate (Ember, Tide, Gale).
# Strictly does NOT calculate or decide the game outcome.
class_name GateController
extends Control

signal gate_clicked(gate_id: int)
signal gate_hovered(gate_id: int)

enum GateType {
	EMBER = 0,
	TIDE = 1,
	GALE = 2
}

@export var gate_type: GateType = GateType.EMBER
@export var shortcut_number: int = 1

var is_hovered: bool = false
var is_pressed: bool = false
var is_disabled: bool = false
var hover_t: float = 0.0
var idle_phase: float = 0.0
var ring_angle: float = 0.0

var primary_color: Color = Color(1.0, 0.65, 0.2)
var secondary_color: Color = Color(1.0, 0.85, 0.4)
var glow_color: Color = Color(1.0, 0.5, 0.1, 0.4)
var gate_title: String = "EMBER GATE"
var gate_subtext: String = "Solar Fire"

# Visual particle sparks
var particles: Array[Dictionary] = []

func _ready() -> void:
	custom_minimum_size = Vector2(240, 340)
	focus_mode = FOCUS_ALL
	_configure_appearance()

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	idle_phase = randf() * TAU

	# Initialize background floating particles
	for i in range(12):
		particles.append({
			"pos": Vector2(randf_range(30, 210), randf_range(60, 280)),
			"vel": Vector2(randf_range(-10, 10), randf_range(-25, -50)),
			"alpha": randf_range(0.3, 0.8),
			"size": randf_range(2.0, 4.5),
			"life": randf()
		})

func _configure_appearance() -> void:
	match gate_type:
		GateType.EMBER:
			primary_color = Color(1.0, 0.62, 0.18)
			secondary_color = Color(1.0, 0.85, 0.45)
			glow_color = Color(1.0, 0.45, 0.1, 0.35)
			gate_title = "EMBER GATE"
			gate_subtext = "Flame of Destiny"
			shortcut_number = 1
		GateType.TIDE:
			primary_color = Color(0.18, 0.85, 0.95)
			secondary_color = Color(0.55, 0.95, 1.0)
			glow_color = Color(0.1, 0.7, 0.9, 0.35)
			gate_title = "TIDE GATE"
			gate_subtext = "Depths of Fortune"
			shortcut_number = 2
		GateType.GALE:
			primary_color = Color(0.78, 0.45, 1.0)
			secondary_color = Color(0.9, 0.7, 1.0)
			glow_color = Color(0.65, 0.3, 0.95, 0.35)
			gate_title = "GALE GATE"
			gate_subtext = "Winds of Fate"
			shortcut_number = 3

func _process(delta: float) -> void:
	idle_phase += delta * 1.5
	ring_angle += delta * (2.2 if is_hovered else 0.8)

	var target_hover: float = 1.0 if (is_hovered and not is_disabled) else 0.0
	hover_t = lerpf(hover_t, target_hover, delta * 10.0)

	# Update particle sparks
	var bounds_w: float = size.x if size.x > 0 else 240.0
	var bounds_h: float = size.y if size.y > 0 else 340.0
	for p in particles:
		p["pos"] += p["vel"] * delta
		p["life"] += delta * 0.8
		if p["life"] > 1.0 or p["pos"].y < 40:
			p["pos"] = Vector2(randf_range(30, bounds_w - 30), bounds_h - randf_range(30, 80))
			p["life"] = 0.0
			p["vel"] = Vector2(randf_range(-12, 12), randf_range(-30, -65))

	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var center_x: float = w * 0.5

	# Hover float offset
	var float_offset_y: float = sin(idle_phase) * (6.0 if not is_disabled else 0.0) - (hover_t * 10.0)
	var gate_rect: Rect2 = Rect2(15, 20 + float_offset_y, w - 30, h - 40)

	# Outer Glow if active / hovered
	if not is_disabled and (hover_t > 0.01 or has_focus()):
		var glow_strength: float = maxf(hover_t, 0.7 if has_focus() else 0.0)
		for g in range(4):
			var spread: float = float(g + 1) * 6.0
			var g_rect: Rect2 = gate_rect.grow(spread)
			var g_col: Color = glow_color
			g_col.a = (0.2 - float(g) * 0.04) * glow_strength
			draw_rounded_rect(g_rect, 24.0 + spread, g_col)

	# Gate Stone Pedestal / Portal Background
	var bg_color: Color = Color(0.08, 0.09, 0.18, 0.95)
	if is_disabled:
		bg_color = Color(0.06, 0.07, 0.12, 0.7)
	draw_rounded_rect(gate_rect, 22.0, bg_color)

	# Inner Arch Border
	var border_color: Color = primary_color if not is_disabled else Color(0.3, 0.35, 0.45)
	var border_width: float = 3.0 + (hover_t * 2.0)
	draw_rounded_rect_outline(gate_rect, 22.0, border_color, border_width)

	# Inner Portal Vortex / Core
	var portal_center: Vector2 = Vector2(center_x, gate_rect.position.y + gate_rect.size.y * 0.42)
	var portal_radius: float = 58.0 + (hover_t * 5.0)

	# Gradient-like depth rings
	for r in range(5, 0, -1):
		var ring_r: float = portal_radius * (float(r) / 5.0)
		var ring_col: Color = primary_color
		ring_col.a = (0.08 * float(r)) * (0.6 if is_disabled else 1.0)
		draw_circle(portal_center, ring_r, ring_col)

	# Rotating Elemental Runic Ring
	var num_dots: int = 8
	for d in range(num_dots):
		var ang: float = ring_angle + (float(d) * (TAU / float(num_dots)))
		var dot_pos: Vector2 = portal_center + Vector2(cos(ang), sin(ang)) * (portal_radius * 0.88)
		var dot_col: Color = secondary_color if not is_disabled else Color(0.4, 0.45, 0.5)
		draw_circle(dot_pos, 3.0 + (hover_t * 1.5), dot_col)

	# Center Mystic Glyph
	_draw_glyph(portal_center, portal_radius * 0.55, border_color)

	# Particles inside gate
	if not is_disabled:
		for p in particles:
			var p_col: Color = secondary_color
			p_col.a = p["alpha"] * (1.0 - p["life"]) * (0.5 + hover_t * 0.5)
			var p_y: float = p["pos"].y + float_offset_y
			if p_y > gate_rect.position.y + 20 and p_y < gate_rect.position.y + gate_rect.size.y - 40:
				draw_circle(Vector2(p["pos"].x, p_y), p["size"], p_col)

	# Shortcut Badge (Key 1, 2, or 3)
	var badge_pos: Vector2 = Vector2(gate_rect.position.x + 28, gate_rect.position.y + 28)
	draw_circle(badge_pos, 16.0, Color(0.04, 0.05, 0.12, 0.9))
	draw_arc(badge_pos, 16.0, 0, TAU, 24, border_color, 2.0)
	var font: Font = ThemeDB.fallback_font
	var key_text: String = str(shortcut_number)
	var font_size: int = 14
	var key_sz: Vector2 = font.get_string_size(key_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, badge_pos + Vector2(-key_sz.x * 0.5, key_sz.y * 0.35), key_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, border_color)

	# Gate Title & Subtext
	var title_y: float = gate_rect.position.y + gate_rect.size.y - 56.0
	var title_sz: Vector2 = font.get_string_size(gate_title, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	var title_col: Color = Color.WHITE if not is_disabled else Color(0.55, 0.6, 0.65)
	draw_string(font, Vector2(center_x - title_sz.x * 0.5, title_y), gate_title, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, title_col)

	var sub_y: float = title_y + 22.0
	var sub_sz: Vector2 = font.get_string_size(gate_subtext, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
	var sub_col: Color = primary_color if not is_disabled else Color(0.4, 0.45, 0.5)
	draw_string(font, Vector2(center_x - sub_sz.x * 0.5, sub_y), gate_subtext, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, sub_col)

func _draw_glyph(center: Vector2, radius: float, col: Color) -> void:
	match gate_type:
		GateType.EMBER:
			# Sun / Flame diamond
			var points: PackedVector2Array = [
				center + Vector2(0, -radius),
				center + Vector2(radius * 0.7, 0),
				center + Vector2(0, radius),
				center + Vector2(-radius * 0.7, 0)
			]
			draw_polyline(points, col, 2.5)
			draw_circle(center, radius * 0.3, secondary_color)
		GateType.TIDE:
			# Water triple-wave ring
			draw_arc(center, radius * 0.75, 0.2, PI - 0.2, 16, col, 2.5)
			draw_arc(center, radius * 0.45, PI + 0.2, TAU - 0.2, 16, col, 2.5)
			draw_circle(center, radius * 0.25, secondary_color)
		GateType.GALE:
			# Winged spiral
			draw_arc(center, radius * 0.8, 0, PI * 1.5, 20, col, 2.5)
			draw_line(center + Vector2(-radius * 0.5, 0), center + Vector2(radius * 0.5, 0), col, 2.5)
			draw_line(center + Vector2(0, -radius * 0.5), center + Vector2(0, radius * 0.5), col, 2.5)
			draw_circle(center, radius * 0.22, secondary_color)

func draw_rounded_rect(rect: Rect2, corner_radius: float, col: Color) -> void:
	var r: float = minf(corner_radius, minf(rect.size.x, rect.size.y) * 0.5)
	var pts: PackedVector2Array = []
	var corners: Array[Vector2] = [
		rect.position + Vector2(r, r),
		rect.position + Vector2(rect.size.x - r, r),
		rect.position + Vector2(rect.size.x - r, rect.size.y - r),
		rect.position + Vector2(r, rect.size.y - r)
	]
	var start_angles: Array[float] = [PI, PI * 1.5, 0.0, PI * 0.5]
	for c in range(4):
		var arc_pts: PackedVector2Array = []
		for step in range(6):
			var a: float = start_angles[c] + (float(step) / 5.0) * (PI * 0.5)
			pts.append(corners[c] + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)

func draw_rounded_rect_outline(rect: Rect2, corner_radius: float, col: Color, width: float) -> void:
	var r: float = minf(corner_radius, minf(rect.size.x, rect.size.y) * 0.5)
	var pts: PackedVector2Array = []
	var corners: Array[Vector2] = [
		rect.position + Vector2(r, r),
		rect.position + Vector2(rect.size.x - r, r),
		rect.position + Vector2(rect.size.x - r, rect.size.y - r),
		rect.position + Vector2(r, rect.size.y - r)
	]
	var start_angles: Array[float] = [PI, PI * 1.5, 0.0, PI * 0.5]
	for c in range(4):
		for step in range(6):
			var a: float = start_angles[c] + (float(step) / 5.0) * (PI * 0.5)
			pts.append(corners[c] + Vector2(cos(a), sin(a)) * r)
	pts.append(pts[0])
	draw_polyline(pts, col, width)

func _gui_input(event: InputEvent) -> void:
	if is_disabled:
		return

	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				is_pressed = true
			else:
				if is_pressed:
					is_pressed = false
					gate_clicked.emit(int(gate_type))

	elif event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE):
			gate_clicked.emit(int(gate_type))

func trigger_selection() -> void:
	if not is_disabled:
		gate_clicked.emit(int(gate_type))

func set_gate_disabled(disabled: bool) -> void:
	is_disabled = disabled
	if disabled:
		is_hovered = false
		is_pressed = false
	queue_redraw()

func _on_mouse_entered() -> void:
	if not is_disabled:
		is_hovered = true
		gate_hovered.emit(int(gate_type))
		queue_redraw()

func _on_mouse_exited() -> void:
	is_hovered = false
	is_pressed = false
	queue_redraw()
