extends KinematicBody2D

onready var anim = $AnimationPlayer
onready var hit_anim = $HitAnimation

export(int) var speed = 250
export(PackedScene) var bullet_scn = preload("res://bullet-prototype/bullets/small_bullet/SmallBullet.tscn")
export(int) var shoot_delay = 1
export(int) var max_ammo = 40

var health = 3
var current_ammo = max_ammo
var current_delay = 0
var can_shoot = false
var can_move = false
var can_take_damage = true
var is_ready = false
var is_stage_complete = false

signal fire
signal damage
signal stage_complete
signal start_stage

func show():
	anim.play("show")

func hide():
	is_stage_complete = true
	anim.play_backwards("show")

func apply_movement():
	if !can_move: return
	
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
	emit_signal("fire")

func apply_shoot_availability():
	if current_ammo == 0:
		return
		
	if current_delay < shoot_delay:
		current_delay += 1
	else:
		can_shoot = true

func update_health():
	can_take_damage = false
	health -= 1
	
	hit_anim.play("hit")
	emit_signal("damage")

func _input(event):
	if event is InputEventMouseButton:
		if event.get_action_strength("fire") and can_shoot:
			create_bullet()
			can_shoot = false

func _process(delta):
	if !is_ready: return
	
	apply_movement()
	rotate_aim()
	apply_shoot_availability()
	pass

func _on_Detection_body_entered(body):
	if body is Bullet:
		if can_take_damage and health > 0:
			update_health()
		body.queue_free()
		
		if health == 0:
			is_stage_complete = true
			emit_signal("stage_complete", "Extraction Incomplete", "Gnar ran out of shield")
	pass # Replace with function body.

func _on_HitAnimation_animation_finished(anim_name):
	if anim_name == "hit":
		can_take_damage = true
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "show" and !is_stage_complete:
		emit_signal("start_stage")
		is_ready = true
		can_shoot = true
		can_move = true
	pass # Replace with function body.
