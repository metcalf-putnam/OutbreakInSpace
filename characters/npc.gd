extends Character
# TODO: add logic for becoming contagious

var direction : Vector2
var path := PoolVector2Array() 
var target : Vector2
var navNode : Navigation2D
var is_wandering := false
var target_type


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
			velocity = move_and_slide(velocity)
			animate_sprite(velocity)
			if (velocity.length() < 0.1 * speed):
				var displace_velocity = Vector2(speed,0).rotated(rng.randf_range(0,2.0*PI))
				set_physics_process(false)
				var new_temp_dest = navNode.get_closest_point(displace_velocity + global_position)
				path = navNode.get_simple_path(new_temp_dest, path[-1])
				yield(get_tree().create_timer(rng.randf_range(0.1, 2.0)), "timeout")
				set_physics_process(true)
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
	path = navNode.get_simple_path(global_position, new_target)
	if path.size() == 0:
		print("you sent me an empty array!")
		return
	set_physics_process(true)


func _on_end_of_path() -> void:
	if is_wandering:
		wander()
	else:
		set_physics_process(false)
		animationState.travel("idle")
		EventHub.emit_signal("building_entered", self)
		wander()


func wander():
	is_wandering = true
	var displace_velocity = Vector2(speed*3,0).rotated(rng.randf_range(0,2.0*PI))
	var new_temp_dest = navNode.get_closest_point(displace_velocity + global_position)
	set_target_location(navNode.get_closest_point(new_temp_dest))

