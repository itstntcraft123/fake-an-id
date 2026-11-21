extends Control

@export var sheet: Texture2D
@export var frame_size := Vector2i(64, 36)
@export var frame_count := 108
@export var fps := 10.0

@onready var texture_rect: TextureRect = $TextureRect
@onready var buttons: Array[Control] = [
	$MarginContainer/VBoxContainer/MainMenu/Start,
	$MarginContainer/VBoxContainer/MainMenu/Options,
	$MarginContainer/VBoxContainer/MainMenu/Quit,
]
@onready var menu: BoxContainer = $MarginContainer/VBoxContainer/MainMenu

func _ready() -> void:
	menu.intro_active = true
	for b in buttons:
		b.modulate.a = 0.0
	
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(0, 0, frame_size.x, frame_size.y)
	texture_rect.texture = atlas
	
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	
	var last := frame_count - 1
	var tween := create_tween()
	tween.tween_method(func(f: float) -> void: atlas.region = Rect2(int(f) * frame_size.x, 0, frame_size.x, frame_size.y), 0.0, float(last), last / fps)
	tween.tween_interval(0.2)
	tween.tween_callback(_reveal_buttons)
	
	await get_tree().process_frame
	for b in buttons:
		b.scale = Vector2.ZERO
	
func _reveal_buttons() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var t := create_tween().set_parallel(true)
	for i in buttons.size():
		var b: Control = buttons[i]
		b.pivot_offset = b.size / 2.0
		var target: Vector2 = menu.hover_scale if b == focused else Vector2.ONE
		b.modulate.a = 1.0
		t.tween_property(b, "scale", target, 0.4).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.finished.connect(func() -> void: menu.intro_active = false)

func _process(_delta: float) -> void:
	pass

func _on_select_menu_selected(_index: int, item: Control) -> void:
	if menu.intro_active:
		return
	match item.name:
		"Start":
			get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
		"Options":
			Utils.switch_scene_as_child(self, "res://scenes/options.tscn", item, [$MarginContainer, $TextureRect])
		"Quit":
			get_tree().quit()
