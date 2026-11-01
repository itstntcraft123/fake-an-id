extends Node2D

@export var escape_screen: PackedScene

func _ready() -> void:
	var gender := Utils.random_gender()
	var age := Utils.random_age()
	var dob := Utils.random_dob(age)
	
	$UI/Control/DriversClassLabel/DriversClass.text = Utils.random_class(age)
	
	$UI/Control/FirstNameLabel/FirstName.text = Utils.random_first_name(gender)
	
	$UI/Control/DoBLabel/DoB.text = Utils.date_to_str(dob)
	$UI/Control/ExpireDateLabel/EXPDate.text = Utils.random_exp(dob)
	
	$UI/Control/SexLabel/Sex.text = gender
	$UI/Control/HeightLabel/Height.text = Utils.random_height()
	$UI/Control/HairLabel/HairColor.text = Utils.random_hair_color()
	$UI/Control/WeightLabel/Weight.text = Utils.random_weight()
	$UI/Control/EyeLabel/EyeColor.text = Utils.random_eye_color()

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true
