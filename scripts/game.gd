extends Node2D

@export var escape_screen: PackedScene

func _ready() -> void:
	var gender := Utils.random_gender()
	var age := Utils.random_age()
	var dob := Utils.random_dob(age)
	var expiry := Utils.random_exp(dob)
	
	$UI/IDCard/DriversClassLabel/DriversClass.text = Utils.random_class(age)
	
	$UI/IDCard/FirstNameLabel/FirstName.text = Utils.random_first_name(gender)
	$UI/IDCard/LastNameLabel/LastName.text = Utils.random_last_name()
	
	$UI/IDCard/DoBLabel/DoB.text = Utils.date_to_str(dob)
	$UI/IDCard/ExpireDateLabel/ExpDate.text = Utils.date_to_str(expiry)
	#$UI/Control/IssueDateLabel/IssueDate.text = Utils.date_to_str(Utils.random_iss(expiry))
	
	$UI/IDCard/SexLabel/Sex.text = gender
	$UI/IDCard/HeightLabel/Height.text = Utils.random_height()
	$UI/IDCard/HairLabel/HairColor.text = Utils.random_hair_color()
	$UI/IDCard/WeightLabel/Weight.text = Utils.random_weight()
	$UI/IDCard/EyeLabel/EyeColor.text = Utils.random_eye_color()

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true
