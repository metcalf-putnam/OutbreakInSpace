extends Character
class_name Player
export var is_contagious = true
export var is_infected = true
var last_direction = Vector2()

export (String, FILE, "*.png") var sprite_file
export (String, FILE, "*.png") var helmet_file

var running_speed = 150
var walking_speed = 100


func _ready():
	position = Global.player_position
	speed = 100
	$AnimationPlayer.playback_speed = 1
	EventHub.connect("player_spoke", self, "speak")
	EventHub.connect("new_dialogue", self, "_on_new_dialogue")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("sing_button_pressed", self, "_on_sing_button_pressed")
	EventHub.connect("sing_button_released", self, "_on_sing_button_released")
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
	
	if get_tree().get_current_scene().get_name() != "House":
		speed = running_speed if Input.get_action_strength("run")  else walking_speed
	
	
	if direction.length() > 0 and state == State.ACTIVE:
		animate_sprite(direction)
		last_direction = direction
		var velocity = direction.normalized() * speed
		velocity = move_and_slide(velocity)
	elif state == State.ACTIVE:
		animationState.travel("idle")

	
func _unhandled_input(event):
	if state != State.ACTIVE:
		return
	if event.is_action_pressed("test") and Global.player_can_test:
		EventHub.emit_signal("testing_character", close_contacts)
		get_tree().set_input_as_handled()


func _on_new_dialogue(_file, _full_name):
	in_dialogue()


func _on_dialogue_finished():
	state = State.ACTIVE


func in_dialogue():
	state = State.DIALOGUE


func _on_sing_button_pressed():
	if state != State.ACTIVE:
		return
	sing_toggled = true
	sing()


func _on_sing_button_released():
	sing_toggled = false


func _on_test_button_pressed():
	if state == State.ACTIVE:
		EventHub.emit_signal("testing_character", close_contacts)


func deactivate_camaera():
	$Camera2D.current = false


func update_sprite():
	if data["has_helmet"] == true:
		Global.player_helmet = true
		$Helmet.show()
	else:
		$Helmet.hide()

	$Sprite.texture = load(sprite_file)
	$Helmet.texture = load(helmet_file)


func _on_Close_body_entered(body):
	._on_Close_body_entered(body)
	if body.is_in_group("character") and Global.player_can_test and !body.is_in_group("player"):
		body.show_glow(true)
		EventHub.emit_signal("testable_character_in_range")
	

func _on_Close_body_exited(body):
	._on_Close_body_exited(body)
	if body.is_in_group("character"):
		body.show_glow(false)
		if close_contacts.size() <= 1:  # player counts as one;; only show when others in range
			EventHub.emit_signal("no_testables_in_range")
		
