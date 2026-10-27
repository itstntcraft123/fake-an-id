extends Node

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

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
