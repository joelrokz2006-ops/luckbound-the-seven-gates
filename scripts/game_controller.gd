# game_controller.gd
# Main gameplay coordinator managing state transitions, HUD, gate inputs, and outcomes.
class_name GameController
extends Control

const OutcomeService = preload("res://scripts/outcome_service.gd")
const ScoringService = preload("res://scripts/scoring_service.gd")
const SaveService = preload("res://scripts/save_service.gd")
const SettingsService = preload("res://scripts/settings_service.gd")
const AudioService = preload("res://scripts/audio_service.gd")
const GateController = preload("res://scripts/gate_controller.gd")
const ResultReveal = preload("res://scripts/result_reveal.gd")
const RunEnd = preload("res://scripts/run_end.gd")

enum GameState {
	MENU = 0,
	READY = 1,
	REVEALING = 2,
	DECISION = 3,
	RUN_ENDED = 4
}

signal return_to_menu_requested

var current_state: GameState = GameState.MENU

# Services
var outcome_service: OutcomeService
var scoring_service: ScoringService
var save_service: SaveService
var settings_service: SettingsService
var audio_service: AudioService

# UI elements
var hud_container: VBoxContainer
var score_label: Label
var round_label: Label
var streak_label: Label
var multiplier_label: Label
var shield_label: Label
var personal_best_label: Label
var gate_container: HBoxContainer
var gates: Array[GateController] = []

var result_reveal: ResultReveal
var run_end_screen: RunEnd
var debug_panel: PanelContainer
var debug_label: Label

# Smooth score rolling display
var displayed_score: float = 0.0

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	_build_ui()

func setup_services(
	p_outcome: OutcomeService,
	p_scoring: ScoringService,
	p_save: SaveService,
	p_settings: SettingsService,
	p_audio: AudioService
) -> void:
	outcome_service = p_outcome
	scoring_service = p_scoring
	save_service = p_save
	settings_service = p_settings
	audio_service = p_audio

func start_new_run() -> void:
	scoring_service.reset_run()
	displayed_score = 0.0
	current_state = GameState.READY
	visible = true
	result_reveal.visible = false
	run_end_screen.visible = false

	_set_gates_disabled(false)
	_update_hud()

func _build_ui() -> void:
	var root_vbox: VBoxContainer = VBoxContainer.new()
	root_vbox.anchor_right = 1.0
	root_vbox.anchor_bottom = 1.0
	root_vbox.add_theme_constant_override("separation", 16)
	add_child(root_vbox)

	# --- TOP HUD BAR ---
	var top_bar: PanelContainer = PanelContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 72)
	var bar_style: StyleBoxFlat = StyleBoxFlat.new()
	bar_style.bg_color = Color(0.04, 0.05, 0.13, 0.88)
	bar_style.border_width_bottom = 2
	bar_style.border_color = Color(0.2, 0.35, 0.65, 0.6)
	bar_style.content_margin_left = 24
	bar_style.content_margin_right = 24
	bar_style.content_margin_top = 8
	bar_style.content_margin_bottom = 8
	top_bar.add_theme_stylebox_override("panel", bar_style)
	root_vbox.add_child(top_bar)

	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_hbox.add_theme_constant_override("separation", 36)
	top_bar.add_child(top_hbox)

	# Round badge
	round_label = Label.new()
	round_label.text = "GATE 1 / 7"
	round_label.add_theme_font_size_override("font_size", 20)
	round_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	top_hbox.add_child(round_label)

	# Unbanked Score
	score_label = Label.new()
	score_label.text = "UNBANKED SCORE: 0"
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.7))
	top_hbox.add_child(score_label)

	# Multiplier
	multiplier_label = Label.new()
	multiplier_label.text = "MULTIPLIER: 1.0x"
	multiplier_label.add_theme_font_size_override("font_size", 18)
	multiplier_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))
	top_hbox.add_child(multiplier_label)

	# Streak
	streak_label = Label.new()
	streak_label.text = "STREAK: 0"
	streak_label.add_theme_font_size_override("font_size", 18)
	streak_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	top_hbox.add_child(streak_label)

	# Shields
	shield_label = Label.new()
	shield_label.text = "SHIELDS: 0"
	shield_label.add_theme_font_size_override("font_size", 18)
	shield_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.85))
	top_hbox.add_child(shield_label)

	# Personal Best
	personal_best_label = Label.new()
	personal_best_label.text = "BEST: 0"
	personal_best_label.add_theme_font_size_override("font_size", 16)
	personal_best_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	top_hbox.add_child(personal_best_label)

	# Menu Button
	var btn_exit: Button = Button.new()
	btn_exit.text = "Exit (Esc)"
	btn_exit.custom_minimum_size = Vector2(90, 34)
	btn_exit.pressed.connect(_on_exit_pressed)
	top_hbox.add_child(btn_exit)

	# --- MIDDLE GATES AREA ---
	var middle_center: CenterContainer = CenterContainer.new()
	middle_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(middle_center)

	gate_container = HBoxContainer.new()
	gate_container.alignment = BoxContainer.ALIGNMENT_CENTER
	gate_container.add_theme_constant_override("separation", 40)
	middle_center.add_child(gate_container)

	# Instantiate the 3 Gates
	for t in [GateController.GateType.EMBER, GateController.GateType.TIDE, GateController.GateType.GALE]:
		var gate: GateController = GateController.new()
		gate.gate_type = t
		gate.gate_clicked.connect(_on_gate_selected)
		gate.gate_hovered.connect(_on_gate_hovered)
		gate_container.add_child(gate)
		gates.append(gate)

	# --- BOTTOM INSTRUCTION HINT ---
	var hint_box: HBoxContainer = HBoxContainer.new()
	hint_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hint_box.custom_minimum_size = Vector2(0, 40)
	root_vbox.add_child(hint_box)

	var hint: Label = Label.new()
	hint.text = "Click a gate or press Keys 1, 2, or 3 to reveal your fate | Press B to Bank | F1 for QA Test Mode"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.55, 0.6, 0.7))
	hint_box.add_child(hint)

	# --- RESULT REVEAL OVERLAY ---
	result_reveal = ResultReveal.new()
	result_reveal.reveal_animation_finished.connect(_on_reveal_animation_finished)
	result_reveal.continue_pressed.connect(_on_continue_round)
	result_reveal.bank_pressed.connect(_on_bank_score)
	result_reveal.view_summary_pressed.connect(_on_view_summary)
	add_child(result_reveal)

	# --- RUN END OVERLAY ---
	run_end_screen = RunEnd.new()
	run_end_screen.play_again_pressed.connect(start_new_run)
	run_end_screen.main_menu_pressed.connect(func(): return_to_menu_requested.emit())
	add_child(run_end_screen)

	# --- DEVELOPER DEBUG / QA PANEL (Hidden by default, toggled with F1) ---
	_build_debug_panel()

func _build_debug_panel() -> void:
	debug_panel = PanelContainer.new()
	debug_panel.visible = false
	debug_panel.custom_minimum_size = Vector2(280, 200)
	debug_panel.position = Vector2(20, 80)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.02, 0.05, 0.95)
	style.border_color = Color(1.0, 0.4, 0.2)
	style.set_border_width_all(2)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	debug_panel.add_theme_stylebox_override("panel", style)
	add_child(debug_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	debug_panel.add_child(vbox)

	debug_label = Label.new()
	debug_label.text = "QA TEST CONTROLS (F1 to hide)\nForce Next Outcome:"
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	vbox.add_child(debug_label)

	var outcomes: Array = [
		["Force Starfall", OutcomeService.OutcomeType.STARFALL],
		["Force Lucky Echo", OutcomeService.OutcomeType.LUCKY_ECHO],
		["Force Guardian Sigil", OutcomeService.OutcomeType.GUARDIAN_SIGIL],
		["Force Void", OutcomeService.OutcomeType.VOID],
		["Clear Force (Normal RNG)", -1]
	]

	for pair in outcomes:
		var btn: Button = Button.new()
		btn.text = pair[0]
		btn.pressed.connect(func():
			if outcome_service:
				if pair[1] == -1:
					outcome_service.clear_forced_outcome()
					debug_label.text = "QA: Forced cleared (Normal RNG)"
				else:
					outcome_service.set_forced_outcome(pair[1])
					debug_label.text = "QA: Forced to %s" % pair[0]
		)
		vbox.add_child(btn)

func _process(delta: float) -> void:
	if not visible:
		return

	# Smooth score increment animation
	if scoring_service:
		var target_score: float = float(scoring_service.run_score)
		if displayed_score != target_score:
			displayed_score = move_toward(displayed_score, target_score, maxf(1.0, abs(target_score - displayed_score) * 12.0 * delta))
			score_label.text = "UNBANKED SCORE: %d" % int(round(displayed_score))

func _update_hud() -> void:
	if not scoring_service:
		return

	round_label.text = "GATE %d / %d" % [scoring_service.current_round, ScoringService.MAX_ROUNDS]
	streak_label.text = "STREAK: %d" % scoring_service.streak
	multiplier_label.text = "MULTIPLIER: %.2fx" % scoring_service.multiplier
	shield_label.text = "SHIELDS: %d" % scoring_service.shields
	if save_service:
		personal_best_label.text = "BEST: %d" % save_service.personal_best

func _set_gates_disabled(disabled: bool) -> void:
	for g in gates:
		g.set_gate_disabled(disabled)

func _on_gate_hovered(_gate_id: int) -> void:
	if current_state == GameState.READY and audio_service:
		audio_service.play_sfx("gate_hover")

func _on_gate_selected(_gate_id: int) -> void:
	if current_state != GameState.READY:
		return

	# Lock input immediately per spec Section 7
	current_state = GameState.REVEALING
	_set_gates_disabled(true)

	if audio_service:
		audio_service.play_sfx("gate_select")

	# Select outcome EXACTLY ONCE before revealing it (spec Section 4 & 7)
	var outcome: int = outcome_service.roll_outcome()

	# Apply game rules and calculate score
	var result_data: Dictionary = scoring_service.apply_outcome(outcome)

	# Play corresponding outcome SFX
	_play_outcome_audio(result_data)

	# Launch reveal visual animation
	var reduced_motion: bool = settings_service.reduced_motion if settings_service else false
	result_reveal.start_reveal(result_data, reduced_motion)

func _play_outcome_audio(result_data: Dictionary) -> void:
	if not audio_service:
		return

	var outcome: int = result_data.get("outcome", 0)
	match outcome:
		OutcomeService.OutcomeType.STARFALL:
			audio_service.play_sfx("starfall")
		OutcomeService.OutcomeType.LUCKY_ECHO:
			audio_service.play_sfx("lucky_echo")
		OutcomeService.OutcomeType.GUARDIAN_SIGIL:
			audio_service.play_sfx("guardian_sigil")
		OutcomeService.OutcomeType.VOID:
			if result_data.get("shield_consumed", false):
				audio_service.play_sfx("shield_block")
			else:
				audio_service.play_sfx("void")

func _on_reveal_animation_finished() -> void:
	_update_hud()
	var run_ended: bool = scoring_service.run_active == false

	if run_ended:
		current_state = GameState.RUN_ENDED
	else:
		current_state = GameState.DECISION

func _on_continue_round() -> void:
	if current_state != GameState.DECISION:
		return

	if audio_service:
		audio_service.play_sfx("button_click")

	result_reveal.visible = false

	# Advance round and update multiplier
	var can_advance: bool = scoring_service.advance_round()
	if can_advance:
		current_state = GameState.READY
		_set_gates_disabled(false)
		_update_hud()
	else:
		# Player survived all 7 gates! Complete victory auto-banks!
		_on_bank_score()

func _on_bank_score() -> void:
	if current_state != GameState.DECISION and current_state != GameState.REVEALING:
		# If user clicks Bank shortcut or survives all 7 rounds
		pass

	current_state = GameState.RUN_ENDED
	result_reveal.visible = false

	var final_score: int = scoring_service.bank_score()
	if audio_service:
		audio_service.play_sfx("bank")

	var is_new_record: bool = false
	if save_service:
		is_new_record = save_service.record_run_result(final_score, scoring_service.streak, true)

	run_end_screen.show_run_summary(
		true,
		final_score,
		0,
		scoring_service.current_round,
		scoring_service.streak,
		is_new_record,
		save_service.personal_best if save_service else final_score
	)

func _on_view_summary() -> void:
	result_reveal.visible = false
	current_state = GameState.RUN_ENDED

	var is_new_record: bool = false
	var is_banked: bool = scoring_service.unbanked_lost == 0 and scoring_service.run_score > 0
	if save_service:
		is_new_record = save_service.record_run_result(scoring_service.run_score, scoring_service.streak, is_banked)

	run_end_screen.show_run_summary(
		is_banked,
		scoring_service.run_score,
		scoring_service.unbanked_lost,
		scoring_service.current_round,
		scoring_service.streak,
		is_new_record,
		save_service.personal_best if save_service else 0
	)

func _on_exit_pressed() -> void:
	return_to_menu_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event: InputEventKey = event as InputEventKey

		# F1 for developer QA overlay
		if key_event.keycode == KEY_F1:
			debug_panel.visible = not debug_panel.visible
			return

		# Gate keyboard shortcuts (1, 2, 3)
		if current_state == GameState.READY:
			if key_event.keycode == KEY_1 and gates.size() > 0:
				gates[0].trigger_selection()
			elif key_event.keycode == KEY_2 and gates.size() > 1:
				gates[1].trigger_selection()
			elif key_event.keycode == KEY_3 and gates.size() > 2:
				gates[2].trigger_selection()

		# Decision state shortcuts
		elif current_state == GameState.DECISION:
			if key_event.keycode == KEY_SPACE or key_event.keycode == KEY_ENTER:
				_on_continue_round()
			elif key_event.keycode == KEY_B:
				_on_bank_score()

		# Run ended state shortcut
		elif current_state == GameState.RUN_ENDED:
			if key_event.keycode == KEY_SPACE or key_event.keycode == KEY_ENTER:
				start_new_run()

		# Escape key returns to menu
		if key_event.keycode == KEY_ESCAPE:
			_on_exit_pressed()
