extends VBoxContainer

signal selected(index: int, item: Control)

var prev_hovered: Control = null
var arrow = "> "
var arrow_right = "   "
var arrow_shown = false
@onready var timer_interval: float = $Timer.wait_time

func _input(event: InputEvent) -> void:
	if event.is_action("ui_down") or event.is_action("ui_up"):
		reset_arrow()
		$Timer.start(timer_interval / 4)
		arrow_shown = false

func _ready() -> void:
	var children = get_children()
	var count = 0
	while count < children.size():
		if children[count] is Button:
			children[count].grab_focus()
		count += 1
	for i in range(children.size()):
		var child = children[i]
		if child is Button:
			var label = RichTextLabel.new()
			label.text = child.text
			child.text = ""
			label.fit_content = true
			label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.bbcode_enabled = true
			child.add_child(label)
			child.pressed.connect(_on_button_pressed.bind(i, child))

func get_hovered_child() -> Control:
	var pos = get_global_mouse_position()
	for child in get_children():
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

func _on_timer_timeout() -> void:
	$Timer.wait_time = timer_interval
	for child in get_children():
		if child is Button and child.visible:
			var label = child.get_child(0)
			if label is RichTextLabel:
				if child == get_viewport().gui_get_focus_owner() and arrow_shown:
					label.text = arrow + remove_prefix(label.text) + arrow_right
				else:
					label.text = remove_prefix(label.text)
	arrow_shown = !arrow_shown

func reset_arrow() -> void:
	for child in get_children():
		if child is Button and child.visible:
			var label = child.get_child(0)
			if label is RichTextLabel:
				label.text = remove_prefix(label.text)

func remove_prefix(text: String):
	return text.trim_prefix(arrow).trim_suffix(arrow_right)
