extends Control

var is_child: bool

func _ready() -> void:
	# temp measure to stop escape_screen from bleeding into options
	if is_child:
		var rect = ColorRect.new()
		rect.color = Color(0.0, 0.0, 0.0, 1.0)
		add_child(rect)
		move_child(rect, 0)
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

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
				queue_free()
			else:
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
