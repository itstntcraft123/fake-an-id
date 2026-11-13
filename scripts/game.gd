extends Node2D

const max_lives := 3
const study_time := 0.0

@export var escape_screen: PackedScene
@export var debug_show_answers := true

var id_data := {}
var lives = max_lives
var score := 0 # for now just # of ids passed

@onready var id_card: Control = $UI/Theme/IDCard
@onready var quiz: Control = $UI/Theme/Quiz
@onready var study_timer: Timer = $StudyTimer
@onready var timer_label: Label = $UI/Theme/TimerLabel
@onready var lives_label: Label = $UI/Theme/LivesLabel
@onready var score_label: Label = $UI/Theme/ScoreLabel
@onready var skip_button: Button = $UI/Theme/SkipButton

func _ready() -> void:
	study_timer.one_shot = true
	study_timer.timeout.connect(_on_study_over)
	quiz.finished.connect(_on_quiz_finished)
	quiz.set_show_answers(debug_show_answers)
	_start_round()

func _start_round() -> void:
	_generate_id()
	quiz.hide()
	skip_button.show()
	id_card.show()
	timer_label.show()
	_update_hud()
	study_timer.start(maxf(8.0, study_time - score))

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
		get_node("UI/Theme/IDCard/" + Utils.snake_to_pascal(key) + "Label/" + Utils.snake_to_pascal(key)).text = id_data[key]

func _process(_delta: float) -> void:
	if not study_timer.is_stopped():
		timer_label.text = str(ceili(study_timer.time_left))

func _on_study_over() -> void:
	skip_button.hide()
	id_card.hide()
	timer_label.hide()
	quiz.show()
	quiz.start(id_data, 2 + score)
	
func _on_quiz_finished(passed: bool) -> void:
	if passed: 
		score += 1
	else: 
		lives -= 1
	_update_hud()
	if lives <= 0:
		_game_over()
	else:
		_start_round()

func _game_over() -> void:
	quiz.hide()
	print("Game over. Score: " + str(score))
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _update_hud() -> void:
	lives_label.text = "Lives: %d" % lives
	score_label.text = "Score: %d" % score

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true

func _on_skip_button_pressed() -> void:
	_on_study_over()
	study_timer.stop()
