extends Character
class_name Player
var last_direction = Vector2()

func _ready():
	speed = 100
	$AnimationPlayer.playback_speed = 1
	EventHub.connect("player_spoke", self, "speak")
	EventHub.connect("new_dialogue", self, "_on_new_dialogue")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")


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
		if Global.energy >= 1:
			EventHub.emit_signal("testing_character", close_contacts)
		else:
			EventHub.emit_signal("insufficient_energy")
		get_tree().set_input_as_handled()
		

func _on_new_dialogue(_file, _full_name):
	state = State.DIALOGUE


func _on_dialogue_finished():
	state = State.ACTIVE

