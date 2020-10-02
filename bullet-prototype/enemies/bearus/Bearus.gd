extends "res://bullet-prototype/enemies/base_enemy.gd"

func _ready():
	init()
	pass # Replace with function body.

func init():
	has_shoot_animations = false
	patterns = {
		"fire-all": ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
		"fire-13579": ["1", "3", "5", "7", "9"],
		"fire-2468": ["2", "4", "6", "8"],
		"fire-234": ["2", "3", "4"],
		"fire-678": ["6", "7", "8"],
		"fire-234678": ["2", "3", "4", "6", "7", "8"],
		"fire-159": ["1", "5", "9"]
	}
	audios = {
		"fire-all": "VirusAttack",
		"fire-13579": "VirusAttack",
		"fire-2468": "VirusAttack",
		"fire-234": "VirusAttack",
		"fire-678": "VirusAttack",
		"fire-234678": "VirusAttack",
		"fire-159": "VirusAttack"
	}
	shoot_patterns = patterns.keys() 
	if shoot_patterns.has("rest"):
		shoot_patterns.remove(patterns.keys().size() - 1) # remove "rest" in the patterns
	shoot_patterns.append("no_shoot") # required to add if no shoot animations
	spawners = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
	first_pattern = "fire-2468"
	current_pattern = first_pattern
	
	health = 100
	$HealthBar.max_value = health
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	$HitAnimation.connect("animation_finished", self, "_on_HitAnimation_animation_finished")
	connect("body_entered", self, "_on_body_entered")
