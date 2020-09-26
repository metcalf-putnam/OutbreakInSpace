extends Area2D

var first_pattern = "fire-1and2"
var current_pattern = first_pattern
var patterns = {
	"fire-1and2": ["1", "2"],
	"fire-3and4": ["3", "4"],
	"fire-5": ["5"],
	"fire-all": ["1", "2", "3", "4", "5"],
	"rest": []
}
var shoot_patterns = ["fire-1and2", "fire-3and4", "fire-5", "fire-all"]
var spawners = ["1", "2", "3", "4", "5"]
var has_shoot_animations = false

onready var anim = $AnimationPlayer
onready var hit_anim = $HitAnimation
onready var health_bar = $HealthBar
onready var health_bar_tween = $HealthBar/Tween

const THRESHOLD_DISTANCE = 10

var health = 20
var speed = 0.3
var can_take_damage = true

var min_location = Vector2(100, 100)
var max_location = Vector2(900, 500)
var desired_location = null

var is_ready = false
var is_stage_complete = false
var hide = false

signal extract
signal start_stage
signal stage_complete

func init():
	patterns = {
		"fire-1and2": ["1", "2"],
		"fire-3and4": ["3", "4"],
		"fire-5": ["5"],
		"fire-all": ["1", "2", "3", "4", "5"],
		"rest": []
	}

func _ready():
	set_process(false)

func _process(delta):
	if is_stage_complete: return
	
	if desired_location == null or position.distance_to(desired_location) < THRESHOLD_DISTANCE:
		desired_location = next_location()
		print("desired", desired_location)
		
	position = position.linear_interpolate(desired_location, delta * speed)

func start_all(paths):
	for path in paths:
		if get_node("SpawnerManager/" + str(path)).get_child_count() > 1:
			for s in get_node("SpawnerManager/" + str(path)).get_children():
				if s is Node2D:
					s.start()
		else:
			get_node("SpawnerManager/" + str(path)).start()
	pass

func stop_all(paths):
	for path in paths:
		if get_node("SpawnerManager/" + str(path)).get_child_count() > 1:
			for s in get_node("SpawnerManager/" + str(path)).get_children():
				if s is Node2D:
					s.stop()
		else:
			get_node("SpawnerManager/" + str(path)).stop()
	pass

func show():
	anim.play("show")

func hide():
	stop_all(spawners)
	set_process(false)
	hide = true
	anim.play_backwards("show")

func next_pattern():
	randomize()
	var pattern
	while true:
		pattern = patterns.keys()[randi() % patterns.size()]
		if pattern != "no_shoot":
			break
	return pattern

func next_location():
	randomize()
	return Vector2(rand_range(min_location.x, max_location.x), rand_range(min_location.y, max_location.y))

func update_health():
#	can_take_damage = false
	health -= 1
	health_bar_tween.interpolate_property(health_bar, "value", health_bar.value, health, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	health_bar_tween.start()
	
	hit_anim.play("hit")
	emit_signal("extract")

func _on_Easy_body_entered(body):
	if body is Bullet:
		if can_take_damage:
			update_health()
			
		body.queue_free()
		
		if health <= 0:
			is_stage_complete = true
			hide()
			emit_signal("stage_complete", "Extraction Complete!", "Gnar eliminated the virus!")
	pass # Replace with function body.d

func _on_AnimationPlayer_animation_finished(anim_name):
	
	if hide: return
	
	if anim_name == "show":
		set_process(true)
		is_ready = true
		emit_signal("start_stage")
		
		if has_shoot_animations:
			anim.play(first_pattern)
		else:
			anim.play("no_shoot")
			
		start_all(patterns[first_pattern])
	elif anim_name in shoot_patterns:
		stop_all(patterns[current_pattern])
	
	if anim_name != "show":
		var pattern = next_pattern()
		current_pattern = pattern
		
		if pattern in shoot_patterns:
			if has_shoot_animations:
				anim.play(pattern)
			else:
				anim.play("no_shoot")
			start_all(patterns[current_pattern])
		else:
			anim.play(pattern)
	pass # Replace with function body.

func _on_HitAnimation_animation_finished(anim_name):
	if anim_name == "hit":
		can_take_damage = true
	pass # Replace with function body.
