extends "res://bullet-prototype/enemies/base_enemy.gd"

func _ready():
	init()
	pass # Replace with function body.

func init():
	has_shoot_animations = false
	patterns = {
		"fire-10": ["10"],
		"fire-11": ["11"]
	}
	audios = {
		"fire-10": "Bass140",
		"fire-11": "VirusAttack"
	}
	shoot_patterns = patterns.keys() 
	if shoot_patterns.has("rest"):
		shoot_patterns.remove(patterns.keys().size() - 1) # remove "rest" in the patterns
	shoot_patterns.append("no_shoot") # required to add if no shoot animations
	spawners = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
	first_pattern = "fire-10"
	current_pattern = first_pattern
	
	health = 50
	threshold_distance = 100
	$HealthBar.max_value = health
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	$HitAnimation.connect("animation_finished", self, "_on_HitAnimation_animation_finished")
	connect("body_entered", self, "_on_body_entered")
