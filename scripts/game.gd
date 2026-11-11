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
@onready var timer_lavel: Label = $UI/TimerLabel
@onready var lives_label: Label = $UI/LivesLabel
@onready var score_label: Label = $UI/ScoreLabel

func _ready() -> void:
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
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true
