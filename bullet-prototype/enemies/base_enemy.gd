extends Area2D

var patterns = {
	"fire-1and2": ["1", "2"],
	"fire-3and4": ["3", "4"],
	"fire-5": ["5"],
	"fire-all": ["1", "2", "3", "4", "5"],
	"rest": []
}

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

var hide = false

signal extract

func _ready():
	stop_all(["1", "2", "3", "4", "5"])
	set_process(false)

func _process(delta):
	if desired_location == null or position.distance_to(desired_location) < THRESHOLD_DISTANCE:
		desired_location = next_location()
		print("desired", desired_location)
		
	position = position.linear_interpolate(desired_location, delta * speed)

func start_all(paths):
	for path in paths:
		for s in get_node("SpawnerManager/" + str(path)).get_children():
			if s is Node2D:
				s.start()
				
func stop_all(paths):
	for path in paths:
		for s in get_node("SpawnerManager/" + str(path)).get_children():
			if s is Node2D:
				s.stop()

func show():
	anim.play("show")

func hide():
	stop_all(["1", "2", "3", "4", "5"])
	set_process(false)
	hide = true
	anim.play_backwards("show")

func next_pattern():
	randomize()
	return patterns.keys()[randi() % patterns.size()]

func next_location():
	randomize()
	return Vector2(rand_range(min_location.x, max_location.x), rand_range(min_location.y, max_location.y))

func update_health():
	can_take_damage = false
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
		
		if health < 0:
			print("Player won!")
	pass # Replace with function body.d

func _on_AnimationPlayer_animation_finished(anim_name):
	
	if hide: return
	
	if anim_name == "show":
		set_process(true)
		anim.play("fire-1and2")
		start_all(patterns["fire-1and2"])
	elif anim_name in ["fire-1and2", "fire-3and4", "fire-5", "fire-all"]:
		stop_all(patterns[anim_name])
	
	if anim_name != "show":
		var pattern = next_pattern()
		print(pattern)
		if pattern in ["fire-1and2", "fire-3and4", "fire-5", "fire-all"]:
			anim.play(pattern)
			start_all(patterns[pattern])
		else:
			anim.play(pattern)
	pass # Replace with function body.

func _on_HitAnimation_animation_finished(anim_name):
	if anim_name == "hit":
		can_take_damage = true
	pass # Replace with function body.
