extends CenterContainer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_select_menu_selected(index: int, item: Control) -> void:
	match item.name:
		"Start":
			get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
		"Options":
			pass
		"Quit":
			get_tree().quit()
