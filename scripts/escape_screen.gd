extends Control

@export var options: PackedScene

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

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
