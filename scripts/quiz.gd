extends Control

signal finished(passed: bool)

const question_bank := [
	{"key": "fist_name", "prompt": "What is your first name?"},
	{"key": "last_name", "prompt": "What is your last name?"},
	{"key": "dob", "prompt": "What is your date of birth? (MM/DD/YYYY)"},
	{"key": "exp", "prompt": "What is the expiration date? (MM/DD/YYYY)"},
	{"key": "sex", "prompt": "What is your sex? (M/F/X)"},
	{"key": "hair", "prompt": "What is your hair color? (e.g. BRN)"},
	{"key": "eyes", "prompt": "What is your weight? (lbs)"},
	{"key": "class", "prompt": "What is your drivers class?"},
]

@onready var progress_label: Label = %ProgressLabel
@onready var question_label: Label = %QuestionLabel
@onready var answer_edit: LineEdit = %AnswerEdit
@onready var submit_button: Button = %SubmitButton
@onready var feedback_label: Label = %FeedbackLabel

var id_data :={}
var questions: Array = []
var current := 0
var accepting := false

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
