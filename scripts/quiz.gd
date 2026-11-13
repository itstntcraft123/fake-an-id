extends Control

var show_answers := true
@onready var debug_label: Label = $DebugAnswerLabel
var clean_regex = RegEx.new()

signal finished(passed: bool)

const question_bank := [
	["first_name", "What is your first name?"],
	["last_name", "What is your last name?"],
	["dob", "What is your date of birth? (MM/DD/YYYY)"],
	["exp_date", "What is the expiration date? (MM/DD/YYYY)"],
	["sex", "What is your sex? (M/F/X)"],
	["weight", "What is your weight? (lbs)"],
	["hair_color", "What is your hair color? (e.g. BRN)"],
	["eye_color", "What is your eye color? (e.g. BRN)"],
	["drivers_class", "What is your license class?"]
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
	clean_regex.compile("[^a-z0-9/]")
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
	
	_refresh_debug()

func _normalize(string: String) -> String:
	return clean_regex.sub(string.to_lower().replace("lbs", "").replace("lb", ""), "", true)

func _on_submit(text: String) -> void:
	if not accepting:
		return
	if text == "" or !text_is_valid(_normalize(text), questions[current][0]):
		feedback_label.text = "Check your answer format!"
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

func set_show_answers(on: bool) -> void:
	show_answers = on
	_refresh_debug()
	
func _refresh_debug() -> void:
	if not is_node_ready():
		return
	debug_label.visible = show_answers and visible and current < questions.size()
	if debug_label.visible:
		debug_label.text = "DEBUG answer: " + str(id_data[questions[current][0]])

# returns if an answer is valid. does not check extensively to allow mistakes while stopping typos.
func text_is_valid(text: String, question: String) -> bool:
	match question:
		_ when question.ends_with("name"):
			return not " " in text
		_ when question.ends_with("date") or question == "dob": # MM/DD/YYYY
			var split := text.split_floats("/", true)
			if len(split) != 3:
				return false
			return split[0] > 0 and split[0] < 13 and split[1] > 0 and split[1] < 32
		"sex":
			return text == "m" or text == "f" or text == "x"
		"weight":
			return text.is_valid_int()
		_ when question.ends_with("color"):
			return len(text) == 3
		"drivers_class":
			print(text)
			return len(text) == 1
		_:
			@warning_ignore("assert_always_true")
			assert(true, "invalid question passed into text_is_valid")
			return false

func _process(_delta: float) -> void:
	pass
