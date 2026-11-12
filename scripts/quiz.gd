extends Control

signal finished(passed: bool)

const question_bank := [
	{"key": "first_name", "prompt": "What is your first name?"},
	{"key": "last_name", "prompt": "What is your last name?"},
	{"key": "dob", "prompt": "What is your date of birth? (MM/DD/YYYY)"},
	{"key": "exp", "prompt": "What is the expiration date? (MM/DD/YYYY)"},
	{"key": "sex", "prompt": "What is your sex? (M/F/X)"},
	{"key": "weight", "prompt": "What is your weight? (lbs)"},
	{"key": "hair", "prompt": "What is your hair color? (e.g. BRN)"},
	{"key": "eyes", "prompt": "What is your eye color? (e.g. BRN)"},
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
	answer_edit.text_submitted.connect(_on_submit)
	submit_button.pressed.connect(func(): _on_submit(answer_edit.text))

func start(data: Dictionary, count: int) -> void:
	id_data = data
	var pool := question_bank.duplicate()
	pool.shuffle()
	questions = pool.slice(0, mini(count, pool.size()))
	current = 0
	_show_question()

func _show_question() -> void:
	progress_label.text = "Question %d / %d" % [current + 1, questions.size()]
	question_label.text = questions[current].prompt
	feedback_label.text = ""
	answer_edit.text = ""
	answer_edit.editable = true
	submit_button.disabled = false
	answer_edit.grab_focus()
	accepting = true

func _normalize(s: String) -> String:
	var t:= s.to_lower().replace("lb", "")
	var out :=""
	for c in t: 
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			out += c
	return out

func _on_submit(text: String) -> void:
	if not accepting: 
		return
	accepting = false
	var correct_answer := str(id_data[questions[current].key])
	
	if _normalize(text) == _normalize(correct_answer):
		current += 1
		if current >= questions.size():
			finished.emit(true)
		else:
			_show_question()
	else:
		answer_edit.editable = false
		submit_button.disabled = true
		feedback_label.text = "Wrong answer buddy. It was: " + correct_answer
		await get_tree().create_timer(1.5).timeout
		finished.emit(false)


func _process(_delta: float) -> void:
	pass
