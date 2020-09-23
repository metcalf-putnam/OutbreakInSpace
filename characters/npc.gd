extends Character
# TODO: add logic for becoming contagious

var direction : Vector2


func _ready():
	get_random_direction()
	$RandDirTimer.start()


func _on_RandDirTimer_timeout():
	get_random_direction()


func get_random_direction():
	var x = rng.randf_range(-1.0, 1.0)
	var y = rng.randf_range(-1.0, 1.0)
	direction = Vector2(x, y).normalized()
	animate_sprite(direction)


func _physics_process(_delta):
	var velocity = direction.normalized() * speed
	velocity = move_and_slide(velocity)
