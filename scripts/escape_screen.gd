extends Control

@export var options: PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_select_menu_selected(index: int, item: Control) -> void:
	get_tree().paused = false
	match item.name:
		"Back":
			queue_free()
		"Options":
			var scene = options.instantiate()
			scene.process_mode = Node.PROCESS_MODE_ALWAYS
			scene.is_child = true
			add_child(scene)
		"Quit":
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
