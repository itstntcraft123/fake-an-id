extends Control

var is_child: bool

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_select_menu_selected(_index: int, item: Control) -> void:
	match item.name:
		"Sounds":
			pass
		"Controls":
			pass
		"Credits":
			pass
		"Back":
			Utils.change_scene_to_file(self, "res://scenes/main_menu.tscn")
