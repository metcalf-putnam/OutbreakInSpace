extends Area2D

var health = 20

var arms_shoot_delay = [2, 2, 2, 2]
var arms_current_delay = [0, 0, 0, 0]

var can_rotate = false
var can_stretch = false
var can_move = false
var can_shoot = true

# ROTATE
var rotate_increment = 1
var rotate_sign = 0
var rotate_delay = 20
var rotate_min_chance = 0.8
var rotate_stop_chance = 0.5
var is_rotate_complete = false
var current_rotate_delay = 0

# SCALE
var scale_increment = 0.01
var scale_sign = Vector2(0,0)
var scale_delay = 20
var scale_min_chance = 0.8
var is_scale_complete = false
var current_scale_delay = 0

# MOVE
var move_increment = 10
var move_sign = Vector2(0,0)
var move_delay = 1
var move_min_chance = 0.8
var is_move_complete = false
var current_move_delay = 0

var rng = RandomNumberGenerator.new()

func want_to_rotate():
	if !can_rotate: return
	
	if current_rotate_delay < rotate_delay:
		current_rotate_delay += 1
	else:
		current_rotate_delay = 0
		if rng.randf() > rotate_min_chance:
			rotation = deg2rad(rng.randf_range(0.0, 360.0))
			for arm in get_node("Arms").get_children():
				for spawner in arm.get_children():
					spawner.bullet_array_starting_angle += rotation

func want_to_stretch():
	if !can_stretch: return
	
	if current_scale_delay < scale_delay:
		current_scale_delay += 1
	else:
		current_scale_delay = 0
		if rng.randf() > scale_min_chance:
			var new_scale = Vector2(rng.randf_range(0.5, 1.5), rng.randf_range(0.5, 1.5))
			scale = new_scale

func want_to_move():
	if !can_move: return
	
	if current_move_delay < move_delay:
		current_move_delay += 1
	else:
		current_move_delay = 0
		if rng.randf() > move_min_chance:
			var new_position = Vector2(rng.randf_range(-1.5, 1.5), rng.randf_range(-1.5, 1.5))
			position += new_position

func _process(delta):
	want_to_rotate()
	want_to_stretch()
	want_to_move()
	pass

func start_stop_spawners(path, arm_no):
	var has_change = -1
	for s in get_node(path).get_children():
		if s is Node2D:
			if s.is_running:
				s.stop()
				has_change = 1
			else:
				s.start()
				has_change = 0
	
	if has_change == 1 and arm_no == 1:
		start_stop_spawners("Arms/3", 3)
		get_node("Arms/3/TimerArm3").start()
		start_stop_spawners("Arms/4", 4)
		get_node("Arms/4/TimerArm4").start()
	elif has_change == 0 and arm_no == 1:
		start_stop_spawners("Arms/3", 3)
		get_node("Arms/3/TimerArm3").stop()
		start_stop_spawners("Arms/4", 4)
		get_node("Arms/4/TimerArm4").stop()
		
	if has_change == 1 and arm_no == 3:
		start_stop_spawners("Arms/5", 5)
		get_node("Arms/5/TimerArm5").start()

func stop_all_spawners():
	get_node("Arms/1/TimerArm1").stop()
	get_node("Arms/2/TimerArm2").stop()
	get_node("Arms/3/TimerArm3").stop()
	get_node("Arms/4/TimerArm4").stop()

func _on_TimerArm1_timeout():
	start_stop_spawners("Arms/1", 1)
	pass # Replace with function body.

func _on_TimerArm2_timeout():
	start_stop_spawners("Arms/2", 2)
	pass # Replace with function body.

func _on_TimerArm3_timeout():
	start_stop_spawners("Arms/3", 3)
	pass # Replace with function body.

func _on_TimerArm4_timeout():
	start_stop_spawners("Arms/4", 4)
	pass # Replace with function body.

func _on_TimerArm5_timeout():
	start_stop_spawners("Arms/5", 5)
	pass # Replace with function body.

func _on_Easy_body_entered(body):
	print(body)
	if body is Bullet:
		health -= 1
		body.queue_free()
		
		if health < 0:
			print("Player won!")
	pass # Replace with function body.d