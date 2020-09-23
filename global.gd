extends Node

var day := 1
var energy := 4
const max_energy := 4

var first_lab_visit := true
var mask_effectiveness := 0.5

var player_can_sing := false
var player_can_test := true
var player_helmet := false
var player_position := Vector2(750, 700)


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
	
func decrement_energy():
	energy -= 1
	EventHub.emit_signal("energy_used")

# MINI GAME global - variables and functions
var player_settings = {
	"ammo": 40,
	"shield": 3,
	"extraction_points": 0,
}
var completed_playthrough = true #set to false

func update_playthrough():
	completed_playthrough = true
###

