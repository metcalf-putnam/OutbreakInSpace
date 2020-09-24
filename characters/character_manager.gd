extends Node

var npcs = []
var core_npcs = {}
var player = {}
var num_npcs := 100
var i := 0
enum Infective{NORMAL, LOW, HIGH}
var rng = RandomNumberGenerator.new()


func _ready():
	if npcs.size() > 0:
		return
	rng.randomize()
	create_player()
	create_family("B4", "Reptiles", 2, 2, 1)
	create_family("A1", "Blues", 2, 2, 1)
	create_family("B1", "Reptiles", 2, 3, 1)
	create_family("A5", "Blues", 2, 2, 2)
	create_family("B7", "Reptiles", 1, 0, 1)
	create_family("A2", "Blues", 1, 3, 0)
	create_family("B2", "Reptiles", 2, 3, 2)
	create_family("A4", "Blues", 2, 2, 2)
	create_family("B3", "Reptiles", 1, 5, 3)
	create_family("A3", "Blues", 2, 2, 2)
	create_family("B6", "Reptiles", 2, 2, 1)

	# Granny lives in B5




func get_core_npc(npc_name):
	if npc_name in core_npcs:
		return core_npcs[npc_name]
	else:
		var dict = {}
		dict["is_infected"] = false
		dict["is_contagious"] = false
		dict["is_symptomatic"] = false
		dict["shed_multiplier"] = get_random_shed()
		dict["viral_load"] = 0.0
		dict["viral_acceptance_rate"] = 0.5
		dict["has_helmet"] = false
		core_npcs[npc_name] = dict
		return dict


func create_player():
	player["is_infected"] = true
	player["is_contagious"] = true
	player["is_symptomatic"] = false
	player["shed_multiplier"] = get_random_shed()
	player["infective_dose"] = 1000
	player["viral_load"] = 0.0
	player["viral_acceptance_rate"] = 0.5
	player["home"] = "player_house"
	player["name"] = "Player McGee"
	player["race"] = "Blues"
	player["type"] = "Woman"
	player["has_helmet"] = false
	print("created player")


func create_family(location, race, adults, kids, elderly):
	var surname = get_random_surname()
	for _i in range(adults):
		create_and_add_npc(location, surname, race, "adult", 1000)
	for _i in range(kids):
		create_and_add_npc(location, surname, race, "Child", 1000)
	for _i in range(elderly):
		create_and_add_npc(location, surname, race, "Elderly", 1000)
	print("total NPCs: ", i)

func create_and_add_npc(home : String, family_name : String, race : String, 
		type : String, infective_dose_mean):
	var dict = create_npc(home, family_name, race, type, infective_dose_mean)
	npcs.append(dict)


func create_npc(home : String, family_name : String, race : String, 
		type : String, infective_dose_mean, first_name = null):
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
			dict["work"] = "Factory1A"
		"Child": 
			dict["work"] = "School"
		"Elderly":
			dict["work"] = "Park"
	
	dict["is_infected"] = false
	dict["is_contagious"] = false
	dict["is_symptomatic"] = false
	dict["shed_multiplier"] = get_random_shed()
	dict["infective_dose"] = get_random_infective_dose(infective_dose_mean)
	dict["viral_load"] = 0.0
	dict["viral_acceptance_rate"] = 0.5
	dict["has_helmet"] = false
	return dict


func get_random_name() -> String:
	# TODO: fill in
	return "Random Name"


func get_random_shed() -> float:
	return 1.0


func get_random_infective_dose(infective_dose_mean) -> float:
	# TODO: make this matter
	return 1000.0


func get_random_surname():
	return "Smith"
	
