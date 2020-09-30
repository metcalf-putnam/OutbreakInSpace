extends Node

var day := 1
var energy := 5
const max_energy := 5
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
var player_can_test := false
var player_helmet := false

# Home flags
var report_read := true # (no report on day 1)
var tv_watched := false

const player_initial_position := Vector2(-340, -528)
const mini_professor_position := Vector2(700, -380)
var player_position := player_initial_position
var test_results = {}
var test_time := 3
var positive_characters = []
var healed_characters = []
var overlord_day := 11
var convinced := false
var npcs_convinced := 0

signal singing_lesson
signal overlord_discovery

var daily_reports = [] 

func _ready():
	EventHub.connect("day_ended", self, "_on_day_ended")
	EventHub.connect("start_mini_game", self, "_on_start_mini_game")
	EventHub.connect("house_entered", self, "_on_house_entered")
	EventHub.connect("house_exited", self, "_on_house_exited")
	CharacterManager.connect("viral_shedding_computed", self, "_on_viral_shedding_computed")


func _on_day_ended():
	print("computing infection spread")
	CharacterManager.compute_daily_viral_shedding()


func reset_daily_values():
	total_infections = total_infections + new_infections
	var new_positives = check_new_positives()
	generate_report(new_positives)
	update_characters_health()
	
	new_infections = 0
	energy = max_energy
	day += 1
	report_read = false
	tv_watched = false
	player_position = player_initial_position


func _on_viral_shedding_computed():
	reset_daily_values()
	
	if day == overlord_day:
		assert(get_tree().change_scene("res://ending.tscn") == OK)
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
		

# MINI GAME global - variables and functions
var character_list_scn = preload("res://ui/CharacterList.tscn")
var mini_game_scn = preload("res://bullet-prototype/Gnar.tscn")
var player_settings = {
	"is_skip": false,
	"mode": "EASY",
	"ammo": 40,
	"shield": 3,
	"extraction_points": 0,
	"total_extraction_points": 0,
	"character_to_help_data": null
}
var completed_playthrough = true #set to false

func update_playthrough():
	completed_playthrough = true


func _on_start_mini_game(data, game_mode):
	Music.fade_current()
	player_settings["character_to_help_data"] = data
	player_settings["mode"] = game_mode
	decrement_energy()
	player_position = mini_professor_position
	get_tree().change_scene("res://bullet-prototype/Gnar.tscn")


func show_positives():
	var character_list = character_list_scn.instance()
	get_tree().root.add_child(character_list)
	pass


func convince_npc():
	convinced = true


func fade_away_explanation():
	# TODO: fix this
#	for npc in CharacterManager.core_npcs:
#		print(npc)
#		if CharacterManager.core_npcs[npc]["npc_handle"] == "work_friend":
#			CharacterManager.core_npcs[npc]["viral_load"] = 900
#		if npc["npc_handle"] == "work_friend":
#			npc["viral_load"] = npc["viral_load"] + 600
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
	var textbox = RichTextLabel.new()
	textbox.clear()
	textbox.append_bbcode("[wave]Daily Report - Day " + str(day) + "[/wave]") 
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode("New infections: " + str(new_infections))
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode("Total infections: " + str(total_infections))
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode("[wave]Test Results:[/wave]")
	if test_results.has(day):
		for test_dic in test_results[day]:
			if test_dic["result"]:
				if not positive_characters.has(test_dic["data"]):
					positive_characters.append(test_dic["data"])
			
			test_dic["data"]["done_test"] = false
			textbox.newline()
			textbox.append_bbcode(format_result(test_dic))
	
	var new_positives_not_tested_by_player = add_new_positives.size() > 0
	if new_positives_not_tested_by_player:
		for positive in add_new_positives:
			var test_dic = {"data": positive, "result": true}
			if not positive_characters.has(test_dic["data"]):
					positive_characters.append(test_dic["data"])
			textbox.newline()
			textbox.append_bbcode(format_result(test_dic))
	
	if !new_positives_not_tested_by_player and !test_results.has(day):
		textbox.append_bbcode("N/A")
	
	# TODO: List dead characters
	daily_reports.append(textbox.text)


func compute_new_health(health, viral_load, infective_dose, cap = 0):
	var viral = viral_load
	if cap != 0 and viral_load > cap:
		viral = cap
	
	var status = CharacterManager.get_infective_dose_status(infective_dose)
	var base_drain = 1 # Moderate
	if status == "Severe":
		base_drain = 2
	elif status == "Critical":
		base_drain = 3
		
	print("base_drain: ", base_drain)
	var health_drain =  (viral / infective_dose) + base_drain
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
			
	for data in CharacterManager.npcs:
		if data["is_symptomatic"]:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])


func check_new_positives():
	var new_positives = []
	for data in CharacterManager.core_npcs:
		if data["health"] < 50 and not Global.positive_characters.has(data):
			new_positives.append(data)
			
	for data in CharacterManager.npcs:
		if data["health"] < 50 and not Global.positive_characters.has(data):
			new_positives.append(data)
	return new_positives


func format_result(test_dic):
	var result_string = "ID: " + str(test_dic["data"]["id"]) + " - " + test_dic["data"]["name"] + ", "
	if test_dic["result"]:
		result_string = result_string + "positive"
	else:
		result_string = result_string + "negative"
	return result_string
