extends Node2D

const max_lives := 3
const study_time := 20.0
const clock_fps := 4.0
const points_per_id := 10

var score := 0
var ids_passed := 0
var skipped := false
var skip_time_left := 0.0

const hud_study_pos := {
	"lives": Vector2(274, 821),
	"score": Vector2(749, 841),
}
const score_study_color := Color("8231de")
const score_quiz_color := Color.YELLOW

const hud_quiz_pos := {
	"lives": Vector2(1395, 230),
	"score": Vector2(1387, 100),
}

var _hearts_shown := max_lives

@export var escape_screen: PackedScene
@export var debug_show_answers := true
@export var debug_show_timer_label := false

var id_data := {}
var lives = max_lives

@onready var id_card: Control = $UI/Theme/IDCard
@onready var quiz: Control = $UI/Theme/Quiz
@onready var study_timer: Timer = $StudyTimer
@onready var timer_label: Label = $UI/Theme/TimerLabel
@onready var timer_anim: AnimatedSprite2D = $UI/TimerAnim
@onready var hearts: HBoxContainer = $UI/Theme/HeartsContainer
@onready var score_label: Label = $UI/Theme/ScoreLabel
@onready var skip_button: Button = $UI/Theme/SkipButton

func _ready() -> void:
	study_timer.one_shot = true
	study_timer.timeout.connect(_on_study_over)
	quiz.finished.connect(_on_quiz_finished)
	quiz.life_lost.connect(_on_life_lost)
	quiz.set_show_answers(debug_show_answers)
	_start_round()

func _on_life_lost() -> void:
	lives -= 1
	_update_hud()
	


func _start_round() -> void:
	skipped = false
	_generate_id()
	quiz.hide()
	skip_button.show()
	id_card.show()
	timer_label.visible = debug_show_timer_label
	_update_hud()
	study_timer.start(maxf(8.0, ceil(study_time - ids_passed * 0.3)))
	timer_anim.show()
	timer_anim.stop()
	_set_clock_frame()
	_set_hud_position(false)

func _generate_id() -> void: 
	var gender := Utils.random_gender()
	var age := Utils.random_age()
	var dob := Utils.random_dob(age)
	var expiry := Utils.random_exp(dob)
	var iss := Utils.random_iss(dob, expiry)
	var license_class := Utils.random_class(age)
	
	id_data = {
		"drivers_class": license_class, 
		"first_name": Utils.random_first_name(gender),
		"last_name": Utils.random_last_name(), 
		"dob": Utils.date_to_str(dob),
		"exp_date": Utils.date_to_str(expiry),
		"sex": gender,
		"height": Utils.random_height(),
		"weight": Utils.random_weight(),
		"eye_color": Utils.random_eye_color(),
		"hair_color": Utils.random_hair_color(),
		"license_no": Utils.random_license_no(),
		"dd": Utils.random_dd(dob, iss, expiry),
		"endorsements": Utils.random_end(license_class),
		"restrictions": Utils.random_restr(license_class),
		"issue_date": Utils.date_to_str(iss),
		"address": Utils.random_address()
	}
	
	for key in id_data:
		var pascal := Utils.snake_to_pascal(key)
		var holder: Control = get_node("UI/Theme/IDCard/" + pascal + "Label")
		holder.visible = Utils.field_unlocked(key, score)
		get_node("UI/Theme/IDCard/" + Utils.snake_to_pascal(key) + "Label/" + Utils.snake_to_pascal(key)).text = id_data[key]

func _set_hud_position(in_quiz: bool) -> void:
	var p := hud_quiz_pos if in_quiz else hud_study_pos
	hearts.position = p["lives"]
	score_label.position = p["score"]
	score_label.add_theme_color_override("font_color", score_quiz_color if in_quiz else score_study_color)

func _process(_delta: float) -> void:
	if study_timer.is_stopped():
		return
	if debug_show_timer_label:
		timer_label.text = str(ceili(study_timer.time_left))
	_set_clock_frame()

func _set_clock_frame() -> void:
	var frame_count := timer_anim.sprite_frames.get_frame_count(timer_anim.animation)
	var sheet_duration := frame_count / clock_fps
	var elapsed_on_sheet := sheet_duration - study_timer.time_left
	timer_anim.frame = clampi(int(elapsed_on_sheet * clock_fps), 0, frame_count - 1)
	# print(progress, " ", frame_count, " ", timer_anim.frame) 

func _on_study_over() -> void:
	skip_button.hide()
	id_card.hide()
	timer_label.hide()
	timer_anim.hide()
	quiz.show()
	_set_hud_position(true)
	quiz.start(id_data, 2 + ids_passed / 2, ids_passed, score)

func _on_quiz_finished(passed: bool) -> void:
	if passed: 
		ids_passed += 1
		score += points_per_id
		if skipped:
			score += roundi(skip_time_left * quiz.questions.size() / 5.0)
		_update_hud()
	if lives <= 0:
		_game_over()
	else:
		_start_round()

func _game_over() -> void:
	quiz.hide()
	Utils.last_ids_passed = ids_passed
	Utils.last_score = score
	print("Game over. \n Score: " + str(score) + "\n IDs passed:" + str(ids_passed))
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _update_hud() -> void:
	score_label.text = "Score: %d" % score
	_update_hearts()

func _update_hearts() -> void:
	var heart_nodes := hearts.get_children()
	for i in heart_nodes.size():
		var heart: Control = heart_nodes[i]
		if i < lives:
			heart.modulate.a = 1.0
		elif i < _hearts_shown:
			_flash_out(heart)
		else:
			heart.modulate.a = 0.0
	_hearts_shown = lives

func _flash_out(heart: Control) -> void:
	var t := heart.create_tween()
	for i in 3:
		t.tween_property(heart, "modulate:a", 0.0, 0.1)
		t.tween_property(heart, "modulate:a", 1.0, 0.1)
	t.tween_property(heart, "modulate:a", 0.0, 0.1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true

func _on_skip_button_pressed() -> void:
	skip_time_left = study_timer.time_left
	skipped = true
	study_timer.stop()
	_on_study_over()
