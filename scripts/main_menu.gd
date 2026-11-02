extends Control

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_select_menu_selected(_index: int, item: Control) -> void:
	match item.name:
		"Start":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		"Options":
			#print("item: ", item) # debugging
			Utils.switch_scene_as_child(self, "res://scenes/options.tscn", item, [$MarginContainer, $TextureRect])
		"Quit":
			get_tree().quit()
