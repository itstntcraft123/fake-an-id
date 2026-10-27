extends Control

var is_child: bool

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_select_menu_selected(index: int, item: Control) -> void:
	match item.name:
		"Sounds":
			pass
		"Controls":
			pass
		"Credits":
			pass
		"Back":
			if is_child:
				process_mode = PROCESS_MODE_INHERIT
				queue_free()
			else:
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
