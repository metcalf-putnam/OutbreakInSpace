extends Character
# TODO: add logic for becoming contagious

var direction : Vector2
var path := PoolVector2Array() 
var target : Vector2
var navNode : Navigation2D

func _ready():
	get_random_direction()
	set_physics_process(false)
	#$RandDirTimer.start()


func set_nav_node(nav_in : Navigation2D):
	navNode = nav_in


func _on_RandDirTimer_timeout():
	get_random_direction()


func get_random_direction():
	var x = rng.randf_range(-1.0, 1.0)
	var y = rng.randf_range(-1.0, 1.0)
	direction = Vector2(x, y).normalized()
	animate_sprite(direction)


func _physics_process(delta):
#	var velocity = direction.normalized() * speed
#	velocity = move_and_slide(velocity)
	move_along_path(delta*speed)


func move_along_path(distance : float) -> void:
	var start_point : = global_position

	while path.size():
		var distance_to_next := start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			var move_rotation = get_angle_to(path[0])
			var velocity = Vector2(speed,0).rotated(move_rotation)
			var collision = move_and_slide(velocity)
			#velocity = move_and_slide(velocity)
			animate_sprite(velocity)
			break
		elif path.size() == 1 && distance > distance_to_next:
			set_physics_process(false)
			_on_end_of_path()
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)


func set_target_location(new_target : Vector2) -> void:
	if !navNode:
		print("no nav2D to navigate with!")
		return
	if new_target.distance_to(global_position) < 2: 
		_on_end_of_path()
		return
	target = new_target
	path = navNode.get_simple_path(global_position, new_target, false)
	if path.size() == 0:
		print("you sent me an empty array!")
		return
	set_physics_process(true)


func _on_end_of_path() -> void:
	set_physics_process(false)
	animationState.travel("idle")
