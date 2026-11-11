extends Control

@onready var instructions: RichTextLabel = %Instructions
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_presed)
	start_button.grab_focus()
	
	
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_presed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
