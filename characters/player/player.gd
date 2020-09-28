extends Character
class_name Player
export var is_contagious = true
export var is_infected = true
var last_direction = Vector2()


func _ready():
	position = Global.player_position
	speed = 100
	$AnimationPlayer.playback_speed = 1
	EventHub.connect("player_spoke", self, "speak")
	EventHub.connect("new_dialogue", self, "_on_new_dialogue")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("sing_button_toggled", self, "_on_sing_button_toggled")
	EventHub.connect("test_button_pressed", self, "_on_test_button_pressed")
	

func init(data):
	.init(data)
	is_infected = data["is_infected"]
	set_contagious(data["is_contagious"])
	if !is_infected:
		add_to_group("susceptible")

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

	
func _unhandled_input(event):
	# TODO: make this different? maybe they can sing on command?
	if state != State.ACTIVE:
		return
	if event.is_action_pressed("ui_accept") and Global.player_can_sing:
		sing()
		get_tree().set_input_as_handled()
	if event.is_action_pressed("test") and Global.player_can_test:
		test()
		get_tree().set_input_as_handled()


func test():
	EventHub.emit_signal("testing_character", close_contacts)


func _on_new_dialogue(_file, _full_name):
	state = State.DIALOGUE


func _on_dialogue_finished():
	state = State.ACTIVE


func _on_sing_button_toggled(boolean):
	sing_toggled = boolean
	if state != State.ACTIVE or !boolean:
		return
	sing()


func _on_test_button_pressed():
	if state == State.ACTIVE:
		test()
