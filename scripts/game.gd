extends Node2D

@export var escape_screen: PackedScene

func _ready() -> void:
	$UI/Control/DoBLabel/DoB.text = Utils.random_dob()

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") and not has_node("EscapeScreen"):
		$UI.add_child(escape_screen.instantiate())
		get_tree().paused = true
