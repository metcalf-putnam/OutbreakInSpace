extends Character

var direction : Vector2
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	get_random_direction()
	$RandDirTimer.start()


func _on_RandDirTimer_timeout():
	get_random_direction()


func get_random_direction():
	var x = rng.randf_range(-1.0, 1.0)
	var y = rng.randf_range(-1.0, 1.0)
	direction = Vector2(x, y)
	animate_sprite()


func animate_sprite():
	$AnimationPlayer.play("walk_left")
	if direction.x <= 0:
		$Sprite.flip_h = false
	else: 
		$Sprite.flip_h = true


func _physics_process(_delta):
	var velocity = direction.normalized() * speed
	velocity = move_and_slide(velocity)

	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	if position.x == 0 or position.x == screen_size.x:
		get_random_direction()
	if position.y == 0 or position.y == screen_size.y:
		get_random_direction()
