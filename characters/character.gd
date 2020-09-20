extends KinematicBody2D
class_name Character

var screen_size
var speed = 15
var animationState : AnimationNodeStateMachinePlayback

var data

# Tracking those in your personal bubble
var close_contacts = []
var very_close_contacts = []

# Spreading infection
var breathing_shed := 5
var speaking_shed := 50
var coughing_shed := 1500
var singing_shed := 100
# TODO: something like outside vs. inside transmission? Or something on size of bubble?

enum State {SINGING, DIALOGUE, ACTIVE}
var state = State.ACTIVE


func _ready():
	screen_size = get_viewport_rect().size
	animationState = $AnimationTree["parameters/playback"]


func init(data_in):
	data = data_in
	update_label()
	update_sprite()
	if data["is_contagious"]:
		$ShedTimer.start()


func update_sprite():
	if data["has_helmet"]: 
		$Helmet.show()
	else:
		$Helmet.hide()
	if !data.has_all(["race", "type"]):
		return
	var sprite_folder_path = "res://characters/" + data["race"] + "/" + data["type"]
	$Sprite.texture = load(sprite_folder_path + "/base_sprite.png")
	$Helmet.texture = load(sprite_folder_path + "/helmet.png")


func add_viral_particles(particles_in : float):
	# TODO: contact tracing element to it?
	data["viral_load"] += particles_in * data["viral_acceptance_rate"]
	if !data["is_infected"]:
		check_status()
	update_label()


func check_status():
	# TODO: logic around fighting infection if at moderate viral load
	if data["viral_load"] >= data["infective_dose"]:
		data["is_infected"] = true
		# TODO: add timer to contagious (and separate timer to symptoms if applicable?)


func update_label():
	if data["is_contagious"]:
		$Label.text = "Contagious"
		$InfectionVisual.modulate.a = 1
	elif data["is_infected"]:
		$Label.text = "Infected"
		$InfectionVisual.modulate.a = 1
	else:
		$Label.text = str(data["viral_load"]) + "/" + str(data["infective_dose"])
		$InfectionVisual.modulate.a = float(data["viral_load"]/data["infective_dose"])


func _on_ShedTimer_timeout():
	if data["is_contagious"]:
		shed_particles()


func shed_particles():
	for body in close_contacts:
		body.add_viral_particles(breathing_shed)
	for body in very_close_contacts:
		body.add_viral_particles(breathing_shed)
	

func set_contagious(boolean):
	data["is_contagious"] = boolean
	remove_from_group("susceptible")
	
	if data["is_contagious"]:
		connect_area_signals()
		$ShedTimer.start()
		
	else:
		disconnect_area_signals()
		$ShedTimer.stop()
	update_label()


func connect_area_signals():
	$VeryClose.connect("body_exited", self, "_on_VeryClose_body_exited")
	$VeryClose.connect("body_entered", self, "_on_VeryClose_body_entered")
	$Close.connect("body_exited", self, "_on_Close_body_exited")
	$Close.connect("body_entered", self, "_on_Close_body_entered")
	
	
func disconnect_area_signals():
	$VeryClose.disconnect("body_exited", self, "_on_VeryClose_body_exited")
	$VeryClose.disconnect("body_entered", self, "_on_VeryClose_body_entered")
	$Close.disconnect("body_exited", self, "_on_Close_body_exited")
	$Close.disconnect("body_entered", self, "_on_Close_body_entered")


func _on_Close_body_entered(body):
	if !close_contacts.has(body) and body.is_in_group("susceptible"):
		close_contacts.append(body)


func _on_VeryClose_body_entered(body):
	if !very_close_contacts.has(body) and body.is_in_group("susceptible"):
		very_close_contacts.append(body)


func _on_Close_body_exited(body):
	if close_contacts.has(body):
		close_contacts.erase(body)


func _on_VeryClose_body_exited(body):
	if very_close_contacts.has(body):
		very_close_contacts.erase(body)


func sing():
	state = State.SINGING
	set_physics_process(false)
	animationState.travel("sing")
	for body in close_contacts:
		body.add_viral_particles(singing_shed)
	for body in very_close_contacts:
		body.add_viral_particles(singing_shed)


func _on_singing_anim_end():
	print("singing ended!")
	if Input.is_action_pressed("ui_accept"):
		sing()
	else:
		state = State.ACTIVE
		set_physics_process(true)


func cough():
	for body in close_contacts:
		body.add_viral_particles(coughing_shed)
	for body in very_close_contacts:
		body.add_viral_particles(coughing_shed)


func animate_sprite(direction : Vector2):
	if state == State.SINGING:
		animationState.travel("sing")
		return
	$AnimationTree.set("parameters/idle/blend_position", direction)
	$AnimationTree.set("parameters/walk/blend_position", direction)
	animationState.travel("walk")
