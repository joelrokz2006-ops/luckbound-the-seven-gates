# celestial_background.gd
# Renders a fantasy indigo night sky with drifting stars, floating ruins, and a celestial compass.
class_name CelestialBackground
extends Control

var stars: Array[Dictionary] = []
var island_points: PackedVector2Array = []
var ruins_points: Array[PackedVector2Array] = []
var compass_angle: float = 0.0
var reduced_motion: bool = false
var time_passed: float = 0.0

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = MOUSE_FILTER_IGNORE
	_init_stars()

func _init_stars() -> void:
	stars.clear()
	for i in range(120):
		stars.append({
			"rel_x": randf(),
			"rel_y": randf(),
			"base_alpha": randf_range(0.3, 0.95),
			"pulse_speed": randf_range(1.5, 4.0),
			"pulse_phase": randf() * TAU,
			"radius": randf_range(1.0, 2.5),
			"color": Color(0.9, 0.95, 1.0) if randf() > 0.3 else (Color(1.0, 0.85, 0.4) if randf() > 0.5 else Color(0.5, 0.85, 1.0))
		})

func _process(delta: float) -> void:
	time_passed += delta
	if not reduced_motion:
		compass_angle += delta * 0.04
	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y

	# Deep indigo cosmic gradient
	var grad_top: Color = Color(0.02, 0.025, 0.07)
	var grad_bottom: Color = Color(0.04, 0.05, 0.14)
	draw_rect(Rect2(0, 0, w, h), grad_top)
	draw_rect(Rect2(0, h * 0.4, w, h * 0.6), grad_bottom)

	# Distant Celestial Compass ring in upper-center
	var compass_pos: Vector2 = Vector2(w * 0.5, h * 0.28)
	var ring_r: float = minf(w, h) * 0.38
	var ring_col: Color = Color(0.18, 0.25, 0.45, 0.12)
	draw_arc(compass_pos, ring_r, 0, TAU, 48, ring_col, 1.5)
	draw_arc(compass_pos, ring_r * 0.65, 0, TAU, 36, ring_col, 1.0)

	# Compass celestial rays
	for i in range(8):
		var ray_ang: float = compass_angle + float(i) * (TAU / 8.0)
		var p1: Vector2 = compass_pos + Vector2(cos(ray_ang), sin(ray_ang)) * (ring_r * 0.5)
		var p2: Vector2 = compass_pos + Vector2(cos(ray_ang), sin(ray_ang)) * (ring_r * 1.05)
		draw_line(p1, p2, Color(0.25, 0.35, 0.6, 0.08), 1.0)

	# Twinkling Stars
	for s in stars:
		var sx: float = s["rel_x"] * w
		var sy: float = s["rel_y"] * h
		var alpha: float = s["base_alpha"]
		if not reduced_motion:
			alpha *= (0.65 + 0.35 * sin(time_passed * s["pulse_speed"] + s["pulse_phase"]))
		var c: Color = s["color"]
		c.a = alpha
		draw_circle(Vector2(sx, sy), s["radius"], c)

	# Distant Floating Island Silhouettes near bottom
	_draw_floating_islands(w, h)

func _draw_floating_islands(w: float, h: float) -> void:
	# Subtle floating island in lower background
	var island_col: Color = Color(0.03, 0.04, 0.09, 0.85)
	var island_pts: PackedVector2Array = [
		Vector2(w * 0.1, h * 0.92),
		Vector2(w * 0.25, h * 0.88),
		Vector2(w * 0.5, h * 0.89),
		Vector2(w * 0.75, h * 0.87),
		Vector2(w * 0.9, h * 0.92),
		Vector2(w * 0.8, h * 0.98),
		Vector2(w * 0.5, h * 1.02),
		Vector2(w * 0.2, h * 0.97)
	]
	draw_colored_polygon(island_pts, island_col)

	# Runic glow on island edge
	draw_polyline(island_pts, Color(0.2, 0.35, 0.6, 0.2), 1.5)
