extends Control

@export var scroll_speed := 60.0 # pixels / sec

var is_child := false

@onready var scroll: ScrollContainer = %Scroll
@onready var content: Control = %Content
@onready var back_button: Button = %BackButton

var tween: Tween

func _ready() -> void:
	back_button.hide()
	back_button.pressed.connect(_exit)
	
	await get_tree().process_frame
	
	for at_top in [true, false]:
		var spacer := Control.new()
		spacer.custom_minimum_size.y = size.y
		content.add_child(spacer)
		if at_top:
			content.move_child(spacer, 0)
			
	await get_tree().process_frame
	
	var max_scroll := int(content.size.y - scroll.size.y)
	tween = create_tween()
	tween.tween_property(scroll, "scroll_vertical", max_scroll, max_scroll / scroll_speed)
	tween.tween_callback(_show_back)

func _show_back() -> void:
	back_button.show()
	back_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_exit()

func _exit() -> void:
	if tween:
		tween.kill()
	Utils.change_scene_to_file(self, "res://scenes/options.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
