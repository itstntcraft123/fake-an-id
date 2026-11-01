extends Node
# Unless cited in the function, the random_ functions do not reflect real data (or do so inaccurately).
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func random_first_name(gender: String) -> String:
	# data from archive.ics.uci.edu/dataset/591/gender+by+name
	var data: Dictionary = read_data("first_names.json")
	
	match gender: 
		"M":
			return weighted_random(data["male_first_names"]).to_upper()
		"F":
			return weighted_random(data["female_first_names"]).to_upper()
		_: 
			return weighted_random(data["male_first_names"].merged(data["female_first_names"])).to_upper()

func random_last_name() -> String:
	# data from www.census.gov/topics/population/genealogy/data/2020_names.html
	return weighted_random(read_data("last_names.json"))

func random_address() -> String:
	var data: Dictionary = read_data("addresses.json")
	
	var street: Array = data["streets"]
	var city: Array = data["cities"]
	var state: Array = data["states"]
	
	return str(randi_range(1000, 9999)) + " " + street.pick_random() + "\n" + \
		city.pick_random() + ", " + state.pick_random() + str(randi_range(1000, 9999))

func random_age() -> int:
	# age group data from www.fhwa.dot.gov/policyinformation/statistics/2023/dl20.cfm
	var age_group: Dictionary = nested_weighted_random(read_data("age_groups.json"))
	return randi_range(age_group["min"], age_group["max"])

func random_dob(age: int) -> Dictionary:
	var current_date := get_date()
	var max_date := current_date.duplicate()
	max_date["year"] -= age
	var min_date := max_date.duplicate()
	min_date["year"] -= 1

	return Time.get_datetime_dict_from_unix_time(randi_range(Time.get_unix_time_from_datetime_dict(min_date), Time.get_unix_time_from_datetime_dict(max_date)))

func date_to_str(date: Dictionary) -> String:
	return str(date["year"]) + "/" + str(date["month"]) + "/" + str(date["day"])

func random_exp(dob: Dictionary) -> String:
	var expired: bool = randf() < 0.2
	var date: Dictionary = dob.duplicate()
	var possible_exps := get_possible_exps(dob, expired)
	date["year"] = possible_exps.pick_random()
	return date_to_str(date)

func get_possible_exps(dob: Dictionary, expired: bool) -> Array[int]:
	var current_year: int = get_date()["year"]
	if expired:
		var year: int = dob["year"] + 18
		var result: Array[int] = []
		while year < current_year:
			result.append(year)
			year += 5
		return result
	else:
		for i in range(current_year, current_year + 6):
			if (i - (dob["year"] + 3)) % 5 == 0 and not is_expired(dob, i):
				return [i]
		return [0]

func is_expired(dob: Dictionary, year: int) -> bool:
	var date := dob.duplicate()
	date["year"] = year
	return date_is_larger(get_date(), date)

func random_class(age: int) -> String:
	return weighted_random({
		"D": 0.7,
		"C": 0.15, # (commercial C, not non-commerical)
		"B": 0.075,
		"A": 0.075
	}) if age >= 18 else "D"

func random_restr(id_class: String) -> String:
	var data := {
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
	var rand := remove_dupes(indep_weighted_random(data))
	rand.sort()
	var result := "".join(rand)
	return result if result != "" else "NONE"

func random_gender() -> String:
	return weighted_random({
		"M": 0.48,
		"F": 0.47,
		"X": 0.05
	})

func random_height() -> String:
	var height := weighted_random_num(58, 96, 67, 3)
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

func get_date() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(max(Time.get_unix_time_from_system(), 1793404800))

func date_is_larger(date1: Dictionary, date2: Dictionary) -> bool:
	return Time.get_unix_time_from_datetime_dict(date1) > Time.get_unix_time_from_datetime_dict(date2)

func weighted_random_num(minimum: float, maximum: float, mean: float, deviation: float) -> float:
	return clampf(rng.randfn(mean, deviation), minimum, maximum)

func test_weighted_random_num_func(function: Callable, tests: int, round_by: int = -1) -> Dictionary:
	var results := {}
	for i in range(tests):
		var rand = function.call() if round_by == -1 else snapped(function.call(), round_by)
		results[rand] = results.get(rand, 0) + 1
	return results

func test_weighted_random_num(minimum: float, maximum: float, mean: float, deviation: float, tests: int, round_by: int) -> Dictionary:
	return test_weighted_random_num_func(func(): return weighted_random_num(minimum, maximum, mean, deviation), tests, round_by)

func weighted_random(dict: Dictionary) -> Variant: # { "key": 0.01 }
	return dict.keys()[rng.rand_weighted(PackedFloat32Array(dict.values()))]

func test_weighted_random_func(function: Callable, tests: int) -> Dictionary:
	var results := {}
	for i in range(tests):
		var rand = function.call()
		results[rand] = results.get(rand, 0) + 1
	for key in results:
		results[key] /= float(tests)
	return results

func test_weighted_random(dict: Dictionary, tests: int) -> Dictionary:
	return test_weighted_random_func(func(): return weighted_random(dict), tests)

func nested_weighted_random(array: Array) -> Dictionary: # [ { "chance": 0.01, "key": "value" } ]
	return array[rng.rand_weighted(PackedFloat32Array(array.map(func(dict): return dict.get("chance"))))]

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
	var file := FileAccess.open("res://data/" + filename, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	return JSON.parse_string(content)

func switch_scene_as_child(parent: Node, path: String, option: Node, hide: Array = [parent.get_node("MarginContainer")]) -> void:
	#print("option: ", option) # debugging
	#print("option: ", option, " valid: ", is_instance_valid(option)) # debugging
	for node in hide:
		if is_instance_valid(node):
			node.hide()
	var parent_prev_mode := parent.process_mode
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	var scene = load(path).instantiate()
	scene.tree_exited.connect(on_tree_exited.bind(parent, option, hide, parent_prev_mode))
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	if "is_child" in scene:
		scene.is_child = true
	parent.add_child(scene)

func on_tree_exited(parent: Node, option: Node, hide: Array = [], parent_prev_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT) -> void:
	for node in hide:
		if is_instance_valid(node):
			node.show()
	parent.process_mode = parent_prev_mode
	option.grab_focus()

func change_scene_to_file(parent: Node, path: String) -> void:
	if parent.is_child:
		parent.queue_free()
	else:
		get_tree().change_scene_to_file(path)
