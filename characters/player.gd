extends Character
class_name Player
var last_direction

func _ready():
	speed = 100
	EventHub.connect("player_spoke", self, "speak")
	EventHub.connect("new_dialogue", self, "_on_new_dialogue")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	print("player position: ", position)
	
func _physics_process(_delta):
	if state == State.SINGING or state == State.DIALOGUE:
		return
		
	var direction = Vector2()
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if direction.length() > 0 and state == State.ACTIVE:
		animate_sprite(direction)
		last_direction = direction
		var velocity = direction.normalized() * speed
		velocity = move_and_slide(velocity)
	elif state == State.ACTIVE:
		animationState.travel("idle")

	position.x = clamp(position.x, 12, screen_size.x - 12)
	position.y = clamp(position.y, 12, screen_size.y - 20)
	
func _unhandled_input(event):
	# TODO: make this different? maybe they can sing on command?
	if event.is_action_pressed("ui_accept") and Global.player_can_sing and state == State.ACTIVE:
		sing()
		

func _on_new_dialogue(_file, _full_name):
	state = State.DIALOGUE


func _on_dialogue_finished():
	state = State.ACTIVE
