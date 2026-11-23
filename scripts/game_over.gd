extends Control

@onready var ids_label: Label = $%IdsLabel
@onready var score_label: Label = $%ScoreLabel
@onready var menu: BoxContainer = $MarginContainer/VBoxContainer/VBoxContainer/SelectMenu

func _ready() -> void:
	Utils.show_intro = true
	ids_label.text = "IDs passed: %d" % Utils.last_ids_passed
	score_label.text = "Score: %d" % Utils.last_score
	menu.selected.connect(_on_select_menu_selected)

func _on_select_menu_selected(_index: int, item: Control) -> void:
	print(item.name)
	match item.name:
		"Restart":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		"Menu":
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
