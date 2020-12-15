extends Node

# Player Language Settings
var default_locale = "en"
var selected_locale = "en"

var active := true
var essential_workers := false
var debug_on := false
var day := 1
var energy := 8
const max_energy := 8
var new_infections := 0
var total_infections := 1
var visuals_on := true
var cookies := 0

# Event flags
var first_lab_visit := true
var first_results := false
var first_positive := false
var first_death := false
var player_test_results := false

var mask_effectiveness := 0.5

var player_can_sing := false
var player_can_test := true
var player_helmet := false

# Home flags
var report_read := true # (no report on day 1)
var tv_watched := false

const player_initial_position := Vector2(-340, -528)
var player_position := player_initial_position
var test_results = {}
var test_time := 1
var positive_characters = []
var healed_characters = []
var dead_characters = []
var overlord_day := 11
var convinced := false
var npcs_convinced := 0
var conversations_had := 0
var songs_sung := 0

signal singing_lesson
signal overlord_discovery
signal fade_away_explanation

var d1s_tested := 0
var idk_quests := false
var daily_reports = [] 
var helmet_mandate := false
var testing_completed := false


func _ready():
	EventHub.connect("day_ended", self, "_on_day_ended")
	EventHub.connect("house_entered", self, "_on_house_entered")
	EventHub.connect("house_exited", self, "_on_house_exited")
	CharacterManager.connect("viral_shedding_computed", self, "_on_viral_shedding_computed")
	EventHub.connect("restart_game", self, "restart_game")
	EventHub.connect("character_tested", self, "_on_character_tested")


func _on_day_ended():
	print("computing infection spread")
	CharacterManager.compute_daily_viral_shedding()


func restart_game(boolean):
	if boolean:
		debug_on = true
	else:
		debug_on = false
	CharacterManager.generate_characters()
	reset_daily_values(true)
	total_infections = 1
	day = 1
	d1s_tested = 0
	positive_characters = []
	daily_reports = []
	dead_characters = []
	testing_completed = false
	conversations_had = 0
	songs_sung = 0
	cookies = 0
	helmet_mandate = false
	essential_workers = false
	
	assert(get_tree().change_scene("res://interiors/Housescene.tscn") == OK)


func reset_daily_values(is_restart = false):
	total_infections = total_infections + new_infections
	update_characters_health()
	var new_positives = check_new_positives()
	day += 1
	if !is_restart:
		generate_report(new_positives)
	
	new_infections = 0
	energy = max_energy

	report_read = false
	tv_watched = false
	player_position = player_initial_position


func _on_viral_shedding_computed():
	reset_daily_values()
	
	if day == overlord_day:
		assert(get_tree().change_scene("res://ending/ending.tscn") == OK)
		return
	
	get_tree().reload_current_scene()


func add_test_results(data, result):
	var test_dic = {"data": data, "result": result}
	if test_results.has(day + test_time):
		test_results[day + test_time].append(test_dic)
	else:
		test_results[day + test_time] = [test_dic]


func increment_cookies():
	cookies += 1


func singing_lesson():
	emit_signal("singing_lesson")
	player_can_sing = true
	


func visit_professor():
	first_lab_visit = false
	player_can_test = true


func decrement_energy():
	if energy <= 0:
		print("error: no energy")
		return
	energy -= 1
	EventHub.emit_signal("energy_used")


func get_character_by_id(id):
	if id == CharacterManager.player_id:
		return get_node("Player")
		


func convince_npc():
	convinced = true


func fade_away_explanation():
	emit_signal("fade_away_explanation")
	CharacterManager.player["has_helmet"] = true
	

func work_party_accepted():
	pass
	

func overlord_discovery():
	emit_signal("overlord_discovery")


func _on_house_entered():
	get_tree().change_scene("res://interiors/Housescene.tscn")


func _on_house_exited():
	get_tree().change_scene("res://root.tscn")


func generate_report(add_new_positives):
	var report = ""
	report += "[wave]Podtown CX-6 Virus Report - Day " + str(day-1) + "[/wave]" + "\n\n"
	report += "New infections: " + str(new_infections) + "\n\n"
	report += "Total infections: " + str(total_infections) + "\n\n"
	report += "[wave]Test Results:[/wave]" + "\n"
	if test_results.has(day):
		first_results = true
		var test_result_table = "[table=4][cell]Name          [/cell][cell]Home          [/cell][cell]Work          [/cell][cell]Result[/cell]"
		for test_dic in test_results[day]:
			if test_dic["result"]:
				print(test_dic)
				if not positive_characters.has(test_dic["data"]):
					positive_characters.append(test_dic["data"])
					first_positive = true
				if test_dic["data"]["id"] == CharacterManager.player_id:
					print("and it was the player!!")
					player_test_results = true
			
			test_dic["data"]["done_test"] = false
			test_result_table += format_result(test_dic)
		test_result_table += "[/table]"
		report += test_result_table
	
	var new_positives_not_tested_by_player = add_new_positives.size() > 0
	if new_positives_not_tested_by_player:
		
		report += "\n\n"
		report += "[wave]New Positive Results from Lab:[/wave]" + "\n"
		var new_test_result_table = "[table=4][cell]Name          [/cell][cell]Home          [/cell][cell]Work          [/cell][cell]Result[/cell]"
		for positive in add_new_positives:
			var test_dic = {"data": positive, "result": true}
			if not positive_characters.has(test_dic["data"]):
				first_positive = true
				positive_characters.append(test_dic["data"])
			new_test_result_table += format_result(test_dic)
		new_test_result_table += "[/table]"
		report += new_test_result_table
		
	if dead_characters.size() > 0:
		print("adding obituaries")
		report += "\n\n"
		report += "[wave]Running Casualties:[/wave]" + "\n"
		var casualties_table = "[table=1][cell]Name[/cell]"
		for character in dead_characters:
			casualties_table += "[cell]" + character["name"] + "[/cell]"
		casualties_table += "[/table]"
		report += casualties_table
	
	daily_reports.append(report)


func compute_new_health(health, viral_load, infective_dose, cap = 0):
	var viral = viral_load
	if cap != 0 and viral_load > cap:
		viral = cap
	
	var status = CharacterManager.get_infective_dose_status(infective_dose)
	var base_drain = 2 # Moderate
	if status == "Severe":
		base_drain = 3
	elif status == "Critical":
		base_drain = 12
		
	print("base_drain: ", base_drain)
	var health_drain =  min(viral / infective_dose, 3) * base_drain
	print("health_drain: ", health_drain)
	return clamp(health - health_drain, 0, 100)


func update_characters_health():
	if CharacterManager.player["is_symptomatic"]:
		var data = CharacterManager.player
		var health = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])
		CharacterManager.player["health"] = health

	for data in CharacterManager.core_npcs:
		if data["is_symptomatic"]:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])
			if data["health"] <= 0:
				if !dead_characters.has(data):
					dead_characters.append(data)
	for data in CharacterManager.npcs:
		if data["is_symptomatic"]:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])
			if data["health"] <= 0:
				if !dead_characters.has(data):
					dead_characters.append(data)

func check_new_positives():
	var new_positives = []
	for data in CharacterManager.core_npcs:
		if data["health"] < 90 and not Global.positive_characters.has(data):
			new_positives.append(data)
			
	for data in CharacterManager.npcs:
		if data["health"] < 90 and not Global.positive_characters.has(data):
			new_positives.append(data)
	return new_positives


func format_result(test_dic):
	var result_string = "[cell]" + test_dic["data"]["name"] + "[/cell]"
	if test_dic["data"].has("home"):
		result_string = result_string + "[cell]" + test_dic["data"]["home"] + "[/cell]"
	else:
		result_string = result_string + "[cell]N/A[/cell]"
	if test_dic["data"].has("work"):
		result_string = result_string + "[cell]" + test_dic["data"]["work"] + "[/cell]"
	else:
		result_string = result_string + "[cell]N/A[/cell]"
	if test_dic["result"]:
		result_string = result_string + "[cell]Positive[/cell]"
	else:
		result_string = result_string + "[cell]Negative[/cell]"
	return result_string


func _on_character_tested(character_data):
	if character_data.has("home") and character_data["home"] == "D1":
		d1s_tested += 1


func activate_idk_quests():
	idk_quests = true


func start_helmet_mandate():
	helmet_mandate = true


func start_essential_worker_mandate():
	essential_workers = true
