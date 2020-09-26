extends Node

var npcs = []
var core_npcs = {}
var core_starting_id = 300

var player = {}
var player_id = 200

var num_npcs := 100
var i := 0
enum Infective{NORMAL, LOW, HIGH}
var rng = RandomNumberGenerator.new()
var workplaces = ["Factory1A", "Factory1B", "Factory1C", "Factory1D", "unemployed"]
var eld_places = ["grocery", "Park1", "Park2"]
var syllables = 	["jack", "nu", "cu", "mo", "knuk", "sus", "ca", "shmu", "bo", "abod", "thl", "mo", "tuk", "foos"]


func _ready():
	if npcs.size() > 0:
		return
	rng.randomize()
	create_player()
	create_family("C1", "Blues", 2, 1, 0, "Parsho")
	create_family("B4", "Reptiles", 2, 1, 1, "Shnooson")
	create_family("C4", "Blues", 2, 1, 1, "Raotao")
	create_family("D1", "Reptiles", 2, 0, 0, "Flarf")
	create_family("D2", "Reptiles", 1, 0, 0, "Klarmore")
	create_family("D1", "Reptiles", 2, 0, 0, "Snuktuk")
	create_family("D2", "Reptiles", 1, 0, 0, "Narkto")
	create_family("D3", "Reptiles", 3, 1, 0, "Shmortl")
	create_family("D1", "Reptiles", 4, 0, 1, "Grurf")
	create_family("D4", "Reptiles", 2, 0, 0, "Duckto")
	create_family("D3", "Reptiles", 1, 0, 0, "Shmortl")
	create_family("D4", "Reptiles", 1, 0, 0, "Duckto")
	create_family("A1", "Blues", 2, 2, 1, "Fuzzlebee")
	create_family("B1", "Reptiles", 2, 1, 1, "Albeback")
	create_family("A5", "Blues", 2, 1, 2, "Gnostnoct")
	create_family("B7", "Reptiles", 1, 0, 1, "Knutl")
	create_family("A2", "Blues", 1, 0, 0, "Fallshtuck")
	create_family("B2", "Reptiles", 2, 0, 2, "Smushl")
	create_family("A4", "Blues", 2, 1, 2, "Bashface")
	create_family("B3", "Reptiles", 1, 2, 3, "Tanyl")
	create_family("A3", "Blues", 2, 1, 2, "Snucksno")
	create_family("B6", "Reptiles", 2, 0, 1, "Beesl")
	

	# Granny lives in B5


func get_core_npc(npc_name):
	if npc_name in core_npcs:
		return core_npcs[npc_name]
	else:
		var dict = {}
		dict["id"] = core_starting_id
		core_starting_id += 1
		dict["is_infected"] = false
		dict["is_contagious"] = false
		dict["is_symptomatic"] = false
		dict["shed_multiplier"] = get_random_shed()
		dict["viral_load"] = 0.0
		dict["viral_acceptance_rate"] = 0.5
		dict["has_helmet"] = false
		dict["done_test"] = false
		dict["health"] = 100.0
		dict["is_alive"] = true
		core_npcs[npc_name] = dict
		return dict


func create_player():
	player["id"] = player_id
	player["is_infected"] = true
	player["is_contagious"] = true
	player["is_symptomatic"] = false
	player["shed_multiplier"] = get_random_shed()
	player["infective_dose"] = 1000
	player["viral_load"] = 10000
	player["viral_acceptance_rate"] = 0.5
	player["home"] = "player_house"
	player["name"] = "Player McGee"
	player["race"] = "Blues"
	player["type"] = "Woman"
	player["has_helmet"] = false
	player["done_test"] = false
	player["health"] = 100.0
	player["is_alive"] = true
	print("created player")


func create_family(location, race, adults, kids, elderly, surname):
	for _i in range(adults):
		create_and_add_npc(location, surname, race, "adult", 1000)
	for _i in range(kids):
		create_and_add_npc(location, surname, race, "Child", 1000)
	for _i in range(elderly):
		create_and_add_npc(location, surname, race, "Elderly", 500)
	print("total NPCs: ", i)


func create_and_add_npc(home : String, family_name : String, race : String, 
		type : String, infective_dose_mean):
	var dict = create_npc(home, family_name, race, type, infective_dose_mean)
	npcs.append(dict)


func create_npc(home : String, family_name : String, race : String, 
		type : String, infective_dose_mean, _first_name = null):
	var dict = {}
	dict["id"] = i
	i += 1
	dict["home"] = home
	dict["name"] = get_random_name() + " " + family_name
	dict["race"] = race
	
	if type != "adult":
		dict["type"] = type
	else:
		var coin_flip = rng.randi_range(0, 1)
		if coin_flip == 1:
			dict["type"] = "Woman"
		else:
			dict["type"] = "Man"
	match type:
		"adult":
			dict["work"] = get_random(workplaces)
		"Child": 
			dict["work"] = get_random(["Class1", "Class2", "Class3"])
		"Elderly":
			dict["work"] = get_random(eld_places)
	dict["is_infected"] = false
	dict["is_contagious"] = false
	dict["is_symptomatic"] = false
	dict["shed_multiplier"] = get_random_shed()
	dict["infective_dose"] = get_random_infective_dose(infective_dose_mean)
	dict["viral_load"] = 0.0
	dict["viral_acceptance_rate"] = 0.5
	dict["has_helmet"] = false
	dict["done_test"] = false
	dict["health"] = 100.0
	dict["is_alive"] = true
	return dict


func get_random_name() -> String:
	var num_syl = rng.randi_range(2, 3)
	var first_name = ""
	for _x in range(num_syl):
		first_name = first_name + get_random(syllables)
	return first_name.capitalize()


func get_random_shed() -> float:
	return 1.0


func get_random_infective_dose(mean) -> float:
	# TODO: make this matter
	# Limit += 200
	return rand_range(mean - 200.0, mean + 200.0)


func get_random_surname():
	return "Smith"

func get_random(array):
	var rand = rng.randi_range(0, array.size()-1)
	return array[rand]
