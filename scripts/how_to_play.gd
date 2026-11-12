extends Control

@onready var instructions: RichTextLabel = %Instructions
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

func _process(_delta: float) -> void:
	pass

func _on_select_menu_selected(index: int, item: Control) -> void:
	match item.name:
		"BackButton":
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		"StartButton":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
