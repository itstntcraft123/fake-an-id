extends Node

const FIELD_MIN_SCORE := {
	"issue_date": 20, 
	"license_no": 40, 
	"restrictions": 70, 
	"endorsements": 70, 
	"address": 100, 
	"dd": 150
}

# for game over screen
var last_ids_passed := 0
var last_score := 0

func field_unlocked(field: String, points: int) -> bool:
	return points > FIELD_MIN_SCORE.get(field, -1)

# Unless cited in the function, the random_ functions do not reflect real data (or do so inaccurately).
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

# Random functions
func random_license_no() -> String:
	return random_string(1) + random_num(7)

func random_first_name(gender: String) -> String:
	# data from archive.ics.uci.edu/dataset/591/gender+by+name (CC BY 4.0)
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
	# address data from github.com/EthanRBrown/rrad from OpenAddresses (public domain)
	var address: Dictionary = read_data("addresses.json")["addresses"].pick_random()
	return address.get("address1", "") + "\n" + address.get("city", "") + ", " + address.get("state", "") + " " + address.get("postalCode", "")

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

func random_exp(dob: Dictionary) -> Dictionary: # expiry date
	var expired: bool = randf() < 0.02 # licenses can be expired (rare)
	var not_eq_dob: bool = randf() < 0.05 # licenses can be not on your dob
	var date: Dictionary = dob.duplicate()
	var possible_exps := get_possible_exps(dob, expired)
	date["year"] = possible_exps.pick_random()
	if not_eq_dob:
		return random_date_in_a_year(date["year"])
	return date

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

# license issue date
func random_iss(dob: Dictionary, expiry: Dictionary) -> Dictionary: # issuing date, 5 years before expiry
	var date: Dictionary = expiry.duplicate()
	var days_before_exp := randi_range(-10, 30) # negative number means they forgot to renew in time
	if date["year"] < dob["year"] + 18:
		date["year"] = dob["year"] + 16 + randi_range(0, 2) if days_before_exp >= 0 else dob["year"] + 16 + randi_range(0,1)
	else:
		date["year"] -= 5
	var unix := Time.get_unix_time_from_datetime_dict(date) - days_before_exp * 60 * 60 * 24
	return Time.get_datetime_dict_from_unix_time(unix)

func random_first_iss(dob: Dictionary, iss: Dictionary) -> Dictionary: # first issue date for random DD
	var min_date: Dictionary = dob.duplicate()
	min_date["year"] += 16
	var max_date: Dictionary = iss.duplicate()
	max_date["year"] -= 1
	return random_date(min_date, max_date)

# document discriminator
func random_dd(dob: Dictionary, iss: Dictionary, expiry: Dictionary) -> String:
	return date_to_str(random_first_iss(dob, iss)) + random_num(3) + random_string(3) + "/" + random_string(2) + str(expiry["year"]).right(2)

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

func random_restr(id_class: String) -> String: # restrictions
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
	rand.slice(0, 6) # avoid overflow in license
	var result := "".join(rand)
	return result if result else "NONE"

func random_end(id_class: String) -> String: # endorsements
	if id_class != "D":
		var rand := remove_dupes(indep_weighted_random({
			"N": 0.35,
			"T": 0.3,
			"H": 0.25,
			"P": 0.15,
			"S": 0.08,
		}))
		rand.sort()
		rand.slice(0, 6) # avoid overflow in license
		var result := "".join(rand)
		return result if result else "NONE"
	return "NONE"

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

# Helper functions
func snake_to_pascal(string: String) -> String:
	return string.capitalize().replace(" ", "")

func date_to_str(date: Dictionary) -> String:
	return str(date["month"]).pad_zeros(2) + "/" + str(date["day"]).pad_zeros(2) + "/" + str(date["year"]).pad_zeros(4)

func random_string(length: int) -> String:
	const alphabet := "abcdefghijklmnopqrstuvwxyz"
	var alphabet_array := Array(alphabet.split())
	var result := ""
	for i in range(length):
		result += alphabet_array.pick_random().to_upper()
	return result

func random_num(length: int) -> String:
	return str(randi_range(0, int("9".repeat(length)))).pad_zeros(length)

func get_date() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(max(Time.get_unix_time_from_system(), 1793404800))

func date_is_larger(date1: Dictionary, date2: Dictionary) -> bool:
	return Time.get_unix_time_from_datetime_dict(date1) > Time.get_unix_time_from_datetime_dict(date2)

func random_date(min_dict: Dictionary, max_dict: Dictionary) -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(randi_range(Time.get_unix_time_from_datetime_dict(min_dict), Time.get_unix_time_from_datetime_dict(max_dict)))

func random_date_in_a_year(year: int) -> Dictionary:
	var min_date = {
		"year": year,
	}
	# get last day, hour, minute in the year by removing 1 second from the unix time of next year
	var max_date = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_datetime_dict({
		"year": year + 1,
	}) - 1)
	return random_date(min_date, max_date)

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
	for node in hide:
		if is_instance_valid(node):
			node.hide()
	var parent_prev_mode := parent.process_mode
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	var scene = load(path).instantiate()
	scene.tree_exited.connect(_on_tree_exited.bind(parent, option, hide, parent_prev_mode))
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	if "is_child" in scene:
		scene.is_child = true
	parent.add_child(scene)

func _on_tree_exited(parent: Node, option: Node, hide: Array = [], parent_prev_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT) -> void:
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
