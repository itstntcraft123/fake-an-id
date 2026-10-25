extends VBoxContainer

signal selected(index: int, item: Control)

var prev_hovered: Control = null

func _ready() -> void:
	var children = get_children()
	children[0].grab_focus()
	for i in range(children.size()):
		var child: Button = children[i]
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(i, child))

func get_hovered_child() -> Control:
	var pos = get_global_mouse_position()
	for child: Control in get_children():
		if child is Control and child.visible and child.get_global_rect().has_point(pos):
			return child
	return null

func _process(delta: float) -> void:
	var hovered = get_hovered_child()
	if hovered and hovered != prev_hovered:
		hovered.grab_focus()
	prev_hovered = hovered

func _on_button_pressed(index: int, item: Control) -> void:
	selected.emit(index, item)
