class_name Bullet
extends RigidBody2D

var first_turn = true

func setup(position, velocity, turnaround = 0, lifetime = 0):
	global_position = position
	linear_velocity = velocity
	
	if turnaround != 0:
		get_node("VisibilityNotifier").disconnect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")
		get_node("VisibilityNotifier").queue_free()
		
		var n_turnaround = get_node("Turnaround")
		n_turnaround.wait_time = turnaround / 2.0
		n_turnaround.start()

	if lifetime != 0:
		var n_lifetime = get_node("Lifetime")
		n_lifetime.wait_time = lifetime
		n_lifetime.start()
	
	set_process(true)

func _ready():
	set_process(false)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.

func _on_Lifetime_timeout():
	queue_free()
	pass # Replace with function body.

func _on_Turnaround_timeout():
	
	if first_turn:
		first_turn = false
		var n_turnaround = get_node("Turnaround")
		n_turnaround.wait_time *= 2.0
		n_turnaround.start()
	
	self.linear_velocity *= -1
	pass # Replace with function body.
