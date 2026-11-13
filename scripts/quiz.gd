extends Control

var show_answers := true
@onready var debug_label: Label = $DebugAnswerLabel

signal finished(passed: bool)

const question_bank := [
	["first_name", "What is your first name?"],
	["last_name", "What is your last name?"],
	["dob", "What is your date of birth? (MM/DD/YYYY)"],
	["exp", "What is the expiration date? (MM/DD/YYYY)"],
	["sex", "What is your sex? (M/F/X)"],
	["weight", "What is your weight? (lbs)"],
	["hair", "What is your hair color? (e.g. BRN)"],
	["eyes", "What is your eye color? (e.g. BRN)"],
	["class", "What is your license class?"]
]

@onready var progress_label: Label = %ProgressLabel
@onready var question_label: Label = %QuestionLabel
@onready var answer_edit: LineEdit = %AnswerEdit
@onready var submit_button: Button = %SubmitButton
@onready var feedback_label: Label = %FeedbackLabel

var id_data := {}
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
	question_label.text = questions[current][1]
	feedback_label.text = ""
	answer_edit.text = ""
	answer_edit.editable = true
	submit_button.disabled = false
	answer_edit.grab_focus()
	accepting = true
	
	accepting = true
	_refresh_debug()

func _normalize(s: String) -> String:
	var t := s.to_lower().replace("lb", "")
	var out := ""
	for c in t: 
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			out += c
	return out

func _on_submit(text: String) -> void:
	if not accepting: 
		return
	accepting = false
	var correct_answer := str(id_data[questions[current][0]])
	
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

func set_show_answers(on:bool) -> void:
	show_answers = on
	_refresh_debug()
	
func _refresh_debug() -> void:
	if not is_node_ready():
		return
	debug_label.visible = show_answers and visible and current < questions.size()
	if debug_label.visible: 
		debug_label.text = "DEBUG answer: " + str(id_data[questions[current][0]])

func _process(_delta: float) -> void:
	pass
