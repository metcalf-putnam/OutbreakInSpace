extends KinematicBody2D

export(int) var speed = 250
export(PackedScene) var bullet_scn = preload("res://bullet-prototype/bullets/small_bullet/SmallBullet.tscn")
export(int) var shoot_delay = 1
export(int) var max_ammo = 100

var health = 3
var current_ammo = max_ammo
var current_delay = 0
var can_shoot = true

func apply_movement():
	var direction = Vector2()
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if direction.length() > 0:
		var velocity = direction.normalized() * speed
		velocity = move_and_slide(velocity)

func get_mouse_angle():
	return get_local_mouse_position().angle()

func rotate_aim():
	rotation += get_mouse_angle() * 0.1

func create_bullet():
	var bullet = bullet_scn.instance()
	var position = get_node("Aim").global_position
	var bullet_speed = 250
	var velocity = Vector2(bullet_speed, 0).rotated(rotation)
	bullet.setup(position, velocity)
	get_tree().get_root().add_child(bullet)
	
	current_ammo -= 1

func apply_shoot_availability():
	if current_ammo == 0:
		return
		
	if current_delay < shoot_delay:
		current_delay += 1
	else:
		can_shoot = true

func _input(event):
	if event is InputEventMouseButton:
		if event.get_action_strength("fire") and can_shoot:
			create_bullet()
			can_shoot = false

func _process(delta):
	apply_movement()
	rotate_aim()
	apply_shoot_availability()
	pass

func _on_Detection_body_entered(body):
	if body is Bullet:
		health -= 1
		body.queue_free()
		
		if health < 0:
			print("Game over player!")
	pass # Replace with function body.
