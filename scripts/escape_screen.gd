extends Control

@export var options: PackedScene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		queue_free()

func _on_select_menu_selected(_index: int, item: Control) -> void:
	match item.name:
		"Back":
			get_tree().paused = false
			queue_free()
		"Options":
			Utils.switch_scene_as_child(self, "res://scenes/options.tscn", item)
		"Quit":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
