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
var speaking_shed := 75
var coughing_shed := 1500
var singing_shed := 100
var mask_multiplier := 1.0

const days_to_contagious := 2
const days_to_symptomatic := 4

# TODO: something like outside vs. inside transmission? Or something on size of bubble?

enum State {SINGING, DIALOGUE, ACTIVE}
var state = State.ACTIVE
var rng = RandomNumberGenerator.new()


func _ready():
	screen_size = get_viewport_rect().size
	animationState = $AnimationTree["parameters/playback"]
	rng.randomize()


func init(data_in):
	data = data_in
	if data.has("contagious_date") and data["contagious_date"] == Global.day:
		data["is_contagious"] = true
		print("now contagious")
	if data.has("symptomatic_date") and data["symptomatic_date"] == Global.day:
		data["is_symptomatic"] = true
		print("now symptomatic")
	update_label()
	update_sprite()
	if data["is_contagious"]:
		$ShedTimer.start()
	if data["is_symptomatic"]:
		$CoughTimer.start(rng.randf_range(8, 90))
	if data["has_helmet"]: 
		mask_multiplier = 1 - Global.mask_effectiveness
		


func update_sprite():
	if data["has_helmet"] == true: 
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
	data["viral_load"] += particles_in * data["viral_acceptance_rate"] * mask_multiplier
	if !data["is_infected"]:
		check_status()
	update_label()


func check_status():
	# TODO: logic around fighting infection if at moderate viral load
	# TODO: account for asymptomatic infections
	if data["viral_load"] >= data["infective_dose"]:
		data["is_infected"] = true
		data["contagious_date"] = Global.day + days_to_contagious
		data["symptomatic_date"] = Global.day + days_to_symptomatic


func update_label():
	if data["is_contagious"] and data["is_symptomatic"]:
		$Label.text = "Contagious and Symptomatic"
		$InfectionVisual.modulate.a = 1
	elif data["is_contagious"]:
		$Label.text = "Contagious"
		$InfectionVisual.modulate.a = 1
	elif data["is_infected"]:
		$Label.text = "Infected"
		$InfectionVisual.modulate.a = 1
	else:
#		$Label.text = str(data["viral_load"]) + "/" + str(data["infective_dose"])
		$InfectionVisual.modulate.a = float(data["viral_load"]/data["infective_dose"])


func _on_ShedTimer_timeout():
	if data["is_contagious"]:
		shed_particles()


func shed_particles():
	for body in close_contacts:
		body.add_viral_particles(breathing_shed * mask_multiplier)
	for body in very_close_contacts:
		body.add_viral_particles(breathing_shed * mask_multiplier)
	

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
	if !$Sing.playing:
		$Sing.play()
	state = State.SINGING
	set_physics_process(false)
	animationState.travel("sing")
	for body in close_contacts:
		body.add_viral_particles(singing_shed * mask_multiplier)
	for body in very_close_contacts:
		body.add_viral_particles(singing_shed * mask_multiplier)


func _on_singing_anim_end():
	if Input.is_action_pressed("ui_accept"):
		sing()
	else:
		state = State.ACTIVE
		set_physics_process(true)
		$Sing.stop()


func speak(_speech_length : int):
	for body in close_contacts:
		body.add_viral_particles(speaking_shed * mask_multiplier)
	for body in very_close_contacts:
		body.add_viral_particles(speaking_shed * mask_multiplier)


func cough():
	animationState.travel("cough")
	if !data["is_contagious"]:
		return
	for body in close_contacts:
		body.add_viral_particles(coughing_shed * mask_multiplier)
	for body in very_close_contacts:
		body.add_viral_particles(coughing_shed * mask_multiplier)


func animate_sprite(direction : Vector2):
	if state == State.SINGING:
		animationState.travel("sing")
		return
	$AnimationTree.set("parameters/idle/blend_position", direction)
	$AnimationTree.set("parameters/walk/blend_position", direction)
	animationState.travel("walk")


func _on_CoughTimer_timeout():
	cough()


func mask_on():
	print("calling mask on function")
	data["has_helmet"] = true
	update_sprite()
	mask_multiplier = 1 - Global.mask_effectiveness


func mask_off():
	data["has_helmet"] = false
	update_sprite()
	mask_multiplier = 1