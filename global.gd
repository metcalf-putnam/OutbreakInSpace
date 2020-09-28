extends Node

var day := 1
var energy := 4
const max_energy := 4
var new_infections := 0
var total_infections := 1
var visuals_on := true
var cookies := 0

var first_lab_visit := true
var mask_effectiveness := 0.5

var player_can_sing := false
var player_can_test := false
var player_helmet := false
const player_initial_position := Vector2(-340, -528)
const mini_professor_position := Vector2(700, -380)
var player_position := player_initial_position
var test_results = {}
var test_time := 3
var positive_characters = []
var healed_characters = []
var overlord_days := 10


func _ready():
	EventHub.connect("day_ended", self, "_on_day_ended")
	EventHub.connect("start_mini_game", self, "_on_start_mini_game")
	CharacterManager.connect("viral_shedding_computed", self, "_on_viral_shedding_computed")


func _on_day_ended():
	CharacterManager.compute_daily_viral_shedding()


func _on_viral_shedding_computed():
	total_infections = total_infections + new_infections
	energy = max_energy
	day += 1
	get_tree().reload_current_scene()
	var morning_report = preload("res://ui/DayStart.tscn").instance()
	get_tree().get_root().add_child(morning_report)


func add_test_results(data, result):
	var test_dic = {"data": data, "result": result}
	if test_results.has(day + test_time):
		test_results[day + test_time].append(test_dic)
	else:
		test_results[day + test_time] = [test_dic]


func increment_cookies():
	cookies += 1


func singing_lesson():
	print("singing lesson being called!")
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


func convince_npc(npc_string):
	pass
#	for npc in CharacterManager.core_npcs:
#		print(CharacterManager.core_npcs[npc])
		# TODO: fix this
#		if CharacterManager.core_npcs[npc]["npc_handle"] == npc_string:
#			CharacterManager.core_npcs[npc]["has_helmet"] = true


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
