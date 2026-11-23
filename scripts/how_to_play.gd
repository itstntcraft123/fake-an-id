extends Control

@onready var instructions: RichTextLabel = %Instructions
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_select_menu_selected(_index: int, item: Control) -> void:
	match item.name:
		"BackButton":
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		"StartButton":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
