extends Character
var last_direction
var screen_size


func _ready():
	screen_size = get_viewport_rect().size
	is_infected = true
	set_contagious(true)

func _physics_process(_delta):
	var direction = Vector2()

	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if direction.length() > 0:
		last_direction = direction
		var velocity = direction.normalized() * speed
		velocity = move_and_slide(velocity)

	position.x = clamp(position.x, 12, screen_size.x - 12)
	position.y = clamp(position.y, 12, screen_size.y - 20)
	
func _unhandled_input(event):
	# TODO: make this different? maybe they can sing on command?
	if event.is_action_pressed("ui_accept"):
		cough()
