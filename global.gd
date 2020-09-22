extends Node

var day := 1
var energy := 4 
const max_energy := 4

var first_lab_visit := true
var mask_effectiveness := 0.5

var player_can_sing := false
var player_can_test := false
var player_helmet := false
var player_position := Vector2(750, 300)



func _ready():
	EventHub.connect("day_ended", self, "_on_day_ended")

func _on_day_ended():
	energy = max_energy
	day += 1
	get_tree().reload_current_scene()


func increment_cookies():
	pass
	
func singing_lesson():
	print("singing lesson being called!")
	player_can_sing = true
	
func visit_professor():
	first_lab_visit = false
	player_can_test = true