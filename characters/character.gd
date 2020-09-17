extends KinematicBody2D
class_name Character

var screen_size
var speed = 25

var is_infected := false
var is_contagious := false setget set_contagious
var is_symptomatic := false

# Getting infected
var infection_limit := 1000.0
var viral_load := 0.0
var viral_acceptance_rate := 0.5

# Tracking those in your personal bubble
var close_contacts = []
var very_close_contacts = []

# Spreading infection
var breathing_shed := 5
var speaking_shed := 50
var coughing_shed := 1500
var singing_shed := 100


func _ready():
	update_label()
	screen_size = get_viewport_rect().size


func add_viral_particles(particles_in : float):
	# TODO: contact tracing element to it?
	viral_load += particles_in * viral_acceptance_rate
	if !is_infected:
		check_status()
	update_label()


func check_status():
	# TODO: logic around fighting infection if at moderate viral load
	if viral_load >= infection_limit:
		is_infected = true
		# TODO: add timer to contagious (and separate timer to symptoms if applicable?)


func update_label():
	if is_contagious:
		$Label.text = "Contagious"
	elif is_infected:
		$Label.text = "Infected"
	else:
		$Label.text = str(viral_load) + "/" + str(infection_limit)
		$InfectionVisual.modulate.a = float(viral_load/infection_limit)


func _on_ShedTimer_timeout():
	if is_contagious:
		shed_particles()


func shed_particles():
	for body in close_contacts:
		body.add_viral_particles(breathing_shed)
	for body in very_close_contacts:
		body.add_viral_particles(breathing_shed)
	

func set_contagious(boolean):
	is_contagious = boolean
	remove_from_group("susceptible")
	
	if is_contagious:
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
	for body in close_contacts:
		body.add_viral_particles(singing_shed)
	for body in very_close_contacts:
		body.add_viral_particles(singing_shed)


func cough():
	for body in close_contacts:
		body.add_viral_particles(coughing_shed)
	for body in very_close_contacts:
		body.add_viral_particles(coughing_shed)
