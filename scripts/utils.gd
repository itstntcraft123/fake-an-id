extends Node

func random_name() -> String:
	var data = read_data("names.json")
	
	var first: Array = data["first_names"]
	var last: Array = data["last_names"]
	return random(first) + random(last)

func random_address() -> String:
	var data = read_data("addresses.json")
	
	var street: Array = data["streets"]
	var city: Array = data["cities"]
	var state: Array = data["states"]
	
	return str(randi_range(1000, 9999)) + " " + random(street) + "\n" + \
		random(city) + ", " + random(state) + str(randi_range(1000, 9999))

func random_dob() -> String:
	const min_date = 0 # a unix timestamp
	var max_date = max(Time.get_unix_time_from_system(), 1288111620)
	
	var random_date = Time.get_datetime_dict_from_unix_time(randi_range(int(min_date), int(max_date)))
	return str(random_date["year"]) + "/" + str(random_date["month"]) + "/" + str(random_date["day"])

func random(array: Array) -> String:
	return array[randi_range(0, array.size())]

func read_data(filename: String) -> Variant:
	var file = FileAccess.open("res://data/" + filename, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content)

func switch_scene_as_child(parent: Node, path: String, option: Node, hide: Array = [parent.get_node("MarginContainer")]) -> void:
	for node in hide:
		node.hide()
	var parent_prev_mode = parent.process_mode
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	var scene = load(path).instantiate()
	scene.tree_exited.connect(on_tree_exited.bind(parent, option, hide, parent_prev_mode))
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	if "is_child" in scene:
		scene.is_child = true
	parent.add_child(scene)

func on_tree_exited(parent: Node, option: Node, hide: Array = [], parent_prev_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT) -> void:
	for node in hide:
		node.show()
	parent.process_mode = parent_prev_mode
	option.grab_focus()

func change_scene_to_file(parent: Node, path: String) -> void:
	if parent.is_child:
		parent.queue_free()
	else:
		get_tree().change_scene_to_file(path)
