extends Control

var is_child: bool

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog"):
		get_viewport().set_input_as_handled()
		Utils.change_scene_to_file(self, "res://scenes/main_menu.tscn")

func _on_select_menu_selected(_index: int, item: Control) -> void:
	match item.name:
		"Sounds":
			pass
		"Controls":
			pass
		"Credits":
			Utils.switch_scene_as_child(self, "res://scenes/credits.tscn", item)
		"Back":
			Utils.change_scene_to_file(self, "res://scenes/main_menu.tscn")
