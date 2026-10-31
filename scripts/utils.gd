extends Node
# Unless cited in the function, the random_ functions do not reflect real data (or do so inaccurately).
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	for i in range(10):
		print(random_restr(random_class()))

func random_first_name(gender: String) -> String:
	var data = read_data("names.json")
	
	match gender: 
		"M":
			return weighted_random(data["male_first_names"])
		"F":
			return weighted_random(data["female_first_names"])
		_: 
			return weighted_random(data["male_first_names"].merged(data["female_first_names"]))

func random_address() -> String:
	var data = read_data("addresses.json")
	
	var street: Array = data["streets"]
	var city: Array = data["cities"]
	var state: Array = data["states"]
	
	return str(randi_range(1000, 9999)) + " " + random(street) + "\n" + \
		random(city) + ", " + random(state) + str(randi_range(1000, 9999))

func random_dob() -> String:
	const min_date = 0 # a unix timestamp
	var max_date = max(Time.get_unix_time_from_system() - 504910816, 1288111620)
	
	var random_date = Time.get_datetime_dict_from_unix_time(randi_range(int(min_date), int(max_date)))
	return str(random_date["year"]) + "/" + str(random_date["month"]) + "/" + str(random_date["day"])

func random_class() -> String:
	return weighted_random({
		"D": 0.7,
		"C": 0.15, # (commercial C, not non-commerical)
		"B": 0.075,
		"A": 0.075
	})

func random_restr(id_class: String) -> String:
	var data = {
		"B": 0.35,
		"C": 0.006,
		"D": 0.002,
		"E": 0.01,
		"F": 0.01,
		"G": 0.02,
		"H": 0.006,
		"I": 0.004,
		"J": 0.01
	}
	if id_class != "D":
		data.merge({
			"E": 0.08,
			"K": 0.05,
			"L": 0.06,
			"M": 0.03,
			"N": 0.03,
			"V": 0.01,
			"Z": 0.02
		})
	var rand = remove_dupes(indep_weighted_random(data))
	rand.sort()
	var result = "".join(rand)
	return result if result != "" else "NONE"

func random_gender() -> String:
	return weighted_random({
		"M": 0.48,
		"F": 0.47,
		"X": 0.05
	})

func random_height() -> String:
	var height = weighted_random_num(58, 96, 67, 3)
	return str(floori(height / 12)) + "'-" + str(int(height) % 12) + "\""

func random_weight() -> String:
	return str(int(weighted_random_num(100, 300, 185, 30))) + " lb"

func random_hair_color() -> String:
	return weighted_random({
		"BRO": 0.5,
		"BLN": 0.30,
		"BLK": 0.15,
		"RED": 0.05
	})

func random_eye_color() -> String:
	# data from pmc.ncbi.nlm.nih.gov/articles/PMC12478955
	return weighted_random({
		"BRO": 0.53,
		"BLU": 0.237,
		"HAZ": 0.103,
		"GRN": 0.09,
		"GRY": 0.007,
		"UNK": 0.033
	})

func random(array: Array) -> Variant:
	return array[randi_range(0, array.size())]

func weighted_random_num(minimum: float, maximum: float, mean: float, deviation: float) -> float:
	return clampf(rng.randfn(mean, deviation), minimum, maximum)

func test_weighted_random_num_func(function: Callable, tests: int, round_by: int = -1) -> Dictionary:
	var results = {}
	for i in range(tests):
		var rand = function.call() if round_by == -1 else snapped(function.call(), round_by)
		results[rand] = results.get(rand, 0) + 1
	return results

func test_weighted_random_num(minimum: float, maximum: float, mean: float, deviation: float, tests: int, round_by: int) -> Dictionary:
	return test_weighted_random_num_func(func(): return weighted_random_num(minimum, maximum, mean, deviation), tests, round_by)

func weighted_random(dict: Dictionary) -> Variant:
	return dict.keys()[rng.rand_weighted(PackedFloat32Array(dict.values()))]

func test_weighted_random_func(function: Callable, tests: int) -> Dictionary:
	var results = {}
	for i in range(tests):
		var rand = function.call()
		results[rand] = results.get(rand, 0) + 1
	for key in results:
		results[key] /= float(tests)
	return results

func test_weighted_random(dict: Dictionary, tests: int) -> Dictionary:
	return test_weighted_random_func(func(): return weighted_random(dict), tests)

func indep_weighted_random(dict: Dictionary) -> Array:
	var results := []
	for item in dict:
		if randf() < dict[item]:
			results.append(item)
	return results

func remove_dupes(array: Array) -> Array:
	var dict := {}
	for item in array:
		dict[item] = ""
	return dict.keys()

func read_data(filename: String) -> Variant:
	var file = FileAccess.open("res://data/" + filename, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content)

func switch_scene_as_child(parent: Node, path: String, option: Node, hide: Array = [parent.get_node("MarginContainer")]) -> void:
	print("option: ", option) # debugging
	print("option: ", option, " valid: ", is_instance_valid(option)) # debugging
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
