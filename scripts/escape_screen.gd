extends Control

@export var options: PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_select_menu_selected(index: int, item: Control) -> void:
	match item.name:
		"Back":
			get_tree().paused = false
			queue_free()
		"Options":
			var scene = options.instantiate()
			scene.process_mode = Node.PROCESS_MODE_ALWAYS
			scene.is_child = true
			scene.tree_exited.connect(_on_options_closed)
			add_child(scene)
			$MarginContainer.hide()
			process_mode = Node.PROCESS_MODE_INHERIT
		"Quit":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_options_closed() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/SelectMenu/Options.grab_focus()
