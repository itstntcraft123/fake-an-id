extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_select_menu_selected(index: int, item: Control) -> void:
	match item.name:
		"Start":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		"Options":
			Utils.switch_scene_as_child(self, "res://scenes/options.tscn", $MarginContainer/VBoxContainer/SelectMenu/Options, [$MarginContainer, $TextureRect])
		"Quit":
			get_tree().quit()
