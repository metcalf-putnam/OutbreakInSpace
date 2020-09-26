extends Node

var day := 1
var energy := 4
const max_energy := 4
var new_infections := 0
var total_infections := 1

var first_lab_visit := true
var mask_effectiveness := 0.5

var player_can_sing := false
var player_can_test := true
var player_helmet := false
var player_position := Vector2(750, 700)
var test_results = {}
var test_time := 2
var positive_ids = []

func _ready():
	EventHub.connect("day_ended", self, "_on_day_ended")
	EventHub.connect("start_mini_game", self, "_on_start_mini_game")


func _on_day_ended():
	total_infections += new_infections
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
	pass


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
	"mode": "EASY",
	"ammo": 40,
	"shield": 3,
	"extraction_points": 0,
	"total_extraction_points": 0,
	"help_character_id": 0
}
var completed_playthrough = true #set to false

func update_playthrough():
	completed_playthrough = true


func _on_start_mini_game(mode = "EASY"):
	player_settings["mode"] = mode
	get_tree().change_scene("res://bullet-prototype/Gnar.tscn")


func show_positives():
	var character_list = character_list_scn.instance()
	get_tree().root.add_child(character_list)
	pass
###

