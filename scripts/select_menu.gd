extends VBoxContainer

signal selected(index: int, item: Control)

const INVIS_PREFIX := "[color=#ffffff00]"
const INVIS_SUFFIX := "[/color]"
var prev_hovered: Control = null
const arrow_prefix := "> "
const arrow_suffix := " >"
var arrow_shown := false
@onready var timer_interval: float = $Timer.wait_time

func _input(event: InputEvent) -> void:
	if event.is_action("ui_down") or event.is_action("ui_up"):
		reset_arrow()
		$Timer.start(timer_interval / 4)
		arrow_shown = false

func _ready() -> void:
	var children = get_children()
	focus_children(children)
	for i in range(children.size()):
		var child = children[i]
		if child is Button:
			var orig_text = child.text.strip_edges()
			var label = RichTextLabel.new()
			label.text = child.text
			child.text = arrow_prefix + orig_text + arrow_suffix
			var min_size = child.get_combined_minimum_size()
			child.custom_minimum_size = min_size
			child.text = ""
			
			label.set_meta("orig_text", orig_text)
			label.add_theme_font_size_override("normal_font_size", child.get_theme_font_size("font_size"))
			label.fit_content = true
			label.add_theme_font_override("normal_font", child.get_theme_font("font"))
			label.autowrap_mode = TextServer.AUTOWRAP_OFF
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.grow_horizontal = Control.GROW_DIRECTION_BOTH
			label.grow_vertical = Control.GROW_DIRECTION_BOTH
			label.bbcode_enabled = true
			label.scroll_active = false
			child.add_child(label)
			label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			
			set_arrow(label, false)
			child.pressed.connect(_on_button_pressed.bind(i, child))

func get_hovered_child() -> Control:
	var pos = get_global_mouse_position()
	for child in get_children():
		if child is Control and child.visible and child.get_global_rect().has_point(pos):
			return child
	return null

func _process(delta: float) -> void:
	var children = get_children()
	if get_viewport().gui_get_focus_owner() not in children:
		focus_children(children)
	var hovered = get_hovered_child()
	if hovered and hovered != prev_hovered:
		reset_arrow()
		hovered.grab_focus()
	prev_hovered = hovered
	update_label()

func _on_button_pressed(index: int, item: Control) -> void:
	selected.emit(index, item)

func _on_timer_timeout() -> void:
	$Timer.wait_time = timer_interval
	for child in get_children():
		if child is Button and child.visible:
			var label = child.get_child(0)
			if label is RichTextLabel:
				set_arrow(label, child == get_viewport().gui_get_focus_owner() and arrow_shown)
	arrow_shown = !arrow_shown

func focus_children(children) -> void:
	var focused = false
	var count = 0
	while count < children.size() and focused == false:
		if children[count] is Button:
			children[count].grab_focus()
			focused = true
		count += 1

func set_arrow(label: RichTextLabel, on: bool) -> void:
	var orig_text = label.get_meta("orig_text")
	var color := label.get_theme_color("default_color").to_html()
	label.text = "[color=#" + color + "]" + arrow_prefix + "[/color]" + orig_text + make_invis(arrow_suffix) if on else make_invis(arrow_prefix) + orig_text + make_invis(arrow_suffix)

func make_invis(text: String) -> String:
	return INVIS_PREFIX + text + INVIS_SUFFIX

func reset_arrow() -> void:
	for child in get_children():
		if child is Button and child.visible:
			var label = child.get_child(0)
			if label is RichTextLabel:
				set_arrow(label, false)

func update_label():
	for child in get_children():
		if child is Button:
			var label = child.get_child(0)
			if label is RichTextLabel:
				if child == get_viewport().gui_get_focus_owner():
					if child.is_pressed():
						label.add_theme_color_override("default_color", child.get_theme_color("font_pressed_color"))
					else:
						label.add_theme_color_override("default_color", child.get_theme_color("font_focus_color"))
				else:
					label.add_theme_color_override("default_color", child.get_theme_color("font_color"))
