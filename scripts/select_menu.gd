extends VBoxContainer

signal selected(index: int, item: Control)

var index := 0
var prev_hovered: Control = null

func _ready() -> void:
	var children = get_children()
	children[0].grab_focus()

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
