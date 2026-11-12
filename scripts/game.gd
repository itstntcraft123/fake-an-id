extends Node2D

const max_lives := 3
const study_time := 20.0

@export var escape_screen: PackedScene

var id_data := {}
var lives = max_lives
var score := 0 # for now just # of ids passed

@onready var id_card: Control = $UI/IDCard
@onready var quiz: Control = $UI/Quiz
@onready var study_timer: Timer = $StudyTimer
@onready var timer_label: Label = $UI/TimerLabel
@onready var lives_label: Label = $UI/LivesLabel
@onready var score_label: Label = $UI/ScoreLabel

func _ready() -> void:
	study_timer.one_shot = true
	study_timer.timeout.connect(_on_study_over)
	quiz.finished.connect(_on_quiz_finished)
	_start_round()

func _start_round() -> void:
	_generate_id()
	quiz.hide()
	id_card.show()
	timer_label.show()
	_update_hud()
	study_timer.start(maxf(8.0, study_time - score))

func _generate_id() -> void: 
	var gender := Utils.random_gender()
	var age := Utils.random_age()
	var dob := Utils.random_dob(age)
	var expiry := Utils.random_exp(dob)
	
	id_data = {
		"class": Utils.random_class(age), 
		"first_name": Utils.random_first_name(gender),
		"last_name": Utils.random_last_name(), 
		"dob": Utils.date_to_str(dob),
		"exp": Utils.date_to_str(expiry),
		"sex": gender,
		"height": Utils.random_height(),
		"weight": Utils.random_weight(),
		"eyes": Utils.random_eye_color(),
		"hair": Utils.random_hair_color(),
	}
	
	$UI/IDCard/DriversClassLabel/DriversClass.text = id_data["class"]
	$UI/IDCard/FirstNameLabel/FirstName.text = id_data["first_name"]
	$UI/IDCard/LastNameLabel/LastName.text = id_data["last_name"]
	$UI/IDCard/DoBLabel/DoB.text = id_data["dob"]
	$UI/IDCard/ExpireDateLabel/ExpDate.text = id_data["dob"]
	$UI/IDCard/SexLabel/Sex.text = id_data["sex"]
	$UI/IDCard/HeightLabel/Height.text = id_data["height"]
	$UI/IDCard/HairLabel/HairColor.text = id_data["hair"]
	$UI/IDCard/WeightLabel/Weight.text = id_data["weight"]
	$UI/IDCard/EyeLabel/EyeColor.text = id_data["eyes"]

func _process(_delta: float) -> void:
	if not study_timer.is_stopped():
		timer_label.text = str(ceili(study_timer.time_left))

func _on_study_over() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true
