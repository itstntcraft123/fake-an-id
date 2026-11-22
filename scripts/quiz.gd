extends Control

var show_answers := true
@onready var debug_label: Label = $DebugAnswerLabel
var clean_regex = RegEx.new()

@export var normal_time := 10.0
@export var fast_time := 5.0
@export var fast_score_threshold := 10

@onready var answer_timer: Timer = $AnswerTimer
@onready var time_left_label: ProgressBar = %TimeLeftBar

var score := 0

signal finished(passed: bool)
signal life_lost

const question_bank := [
	["first_name", "What is your first name?"],
	["last_name", "What is your last name?"],
	["dob", "What is your date of birth? (MM/DD/YYYY)"],
	["exp_date", "What is the expiration date? (MM/DD/YYYY)"],
	["sex", "What is your sex? (M/F/X)"],
	["weight", "What is your weight? (lbs)"],
	["hair_color", "What is your hair color? (e.g. BRN)"],
	["eye_color", "What is your eye color? (e.g. BRN)"],
	["drivers_class", "What is your license class?"],
	["issue_date", "What is the issue date? (MM/DD/YYYY)"], 
	["license_no", "What are the last 3 digits of your license number?", "last3"], 
	["restrictions", "What are your restrictions? (NONE of none)"], 
	["endorsements", "What are your endorsements? (NONE of none)"], 
	["address", "What sttate do you live in? (e.g. CA)", "state"], 
	["dd", "What are the last 4 characters of your DD?", "last4"],
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
	
	answer_timer.one_shot = true
	answer_timer.timeout.connect(_on_time_up)

func start(data: Dictionary, count: int, current_score: int = 0, points: int = 0) -> void:
	id_data = data
	score = current_score
	var pool := question_bank.filter(func(q:Array) -> bool: return Utils.field_unlocked(q[0], points))
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
	answer_timer.start(fast_time if score >= fast_score_threshold else normal_time)
	time_left_label.max_value = answer_timer.wait_time
	_refresh_debug()

func _normalize(string: String) -> String:
	return clean_regex.sub(string.to_lower().replace("lbs", "").replace("lb", ""), "", true)

func _on_submit(text: String) -> void:
	if not accepting:
		return
	
	var correct_answer := _correct_answer()
	if _normalize(text) == _normalize(correct_answer):
		accepting = false
		answer_timer.stop()
		current += 1
		if current >= questions.size():
			finished.emit(true)
		else: 
			_show_question()
	else:
		_fail("Wrong answer buddy. It was: ")

func _correct_answer() -> String:
	var q: Array = questions[current]
	var value:= str(id_data[q[0]])
	var mode: String = q[2] if q.size() > 2 else ""
	match mode:
		"last3":
			return value.right(3)
		"last4":
			return value.right(4)
		"state":
			return value.split("\n")[-1].split(",")[-1].strip_edges().split(" ")[0]
		_:
			return value

func _fail(message: String) -> void:
	accepting = false
	answer_timer.stop()
	answer_edit.editable = false
	submit_button.disabled = true
	var correct_answer := _correct_answer()
	feedback_label.text = message + correct_answer
	life_lost.emit()
	await get_tree().create_timer(1.5).timeout
	finished.emit(false)

func _on_time_up() -> void:
	if accepting:
		_fail("Time is up! It was: ")

func set_show_answers(on: bool) -> void:
	show_answers = on
	_refresh_debug()
	
func _refresh_debug() -> void:
	if not is_node_ready():
		return
	debug_label.visible = show_answers and visible and current < questions.size()
	if debug_label.visible:
		debug_label.text = "DEBUG answer: " + _correct_answer()

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
			return len(text) == 1
		_:
			@warning_ignore("assert_always_true")
			assert(true, "invalid question passed into text_is_valid")
			return false

func _process(_delta: float) -> void:
	if time_left_label and not answer_timer.is_stopped():
		time_left_label.value = answer_timer.time_left
