extends Node2D

var bullet_scn = preload("res://bullet-prototype/bullet/Bullet.tscn")

export(int, 1, 5) var total_bullet_arrays = 1
export(int, 0, 360, 5) var bullet_array_starting_angle = 0 # starting angle of the bullet
export(float, 0, 360, 5) var total_array_spread = 90.0

export(int, 1, 10) var bullets_per_array = 3
export(float, 0, 360, 5) var individual_array_spread = 90.0

export(int) var spin_speed = 0 # positive = counter clock wise, negative = clock wise
export(int, 0, 50) var spin_speed_rate = 0
export(int, 1) var spin_reversal = 1 # 0 = off, 1 = on
export(int, 1) var current_spin = 1 # 0 - clockwise, 1 - counterclockwise
export(int, 0, 360, 5) var max_spin_reversal = 90
var current_spin_speed_rate = 0

export(int, 0, 50) var fire_rate = 4
var current_fire_rate = 0
export(int, 1) var alternating_fire = 0 # 0 = off, 1 = on
export(int, 1) var current_alternating_fire = 0 # 0 = odd or 1 = even
export(int) var bullet_speed = 350
export(int) var life_time_in_seconds = 0 # time it takes until it will be remove from the scene 

func compute_array_spread(total):
	if total == 1: return 0;
	
	return deg2rad(total_array_spread / (total - 1.0))

func compute_individual_array_spread(total):
	if total == 1: return 0;
	
	return deg2rad(individual_array_spread / (total - 1.0)) 

func create_bullet():
	var bullet = bullet_scn.instance();
	get_tree().get_root().add_child(bullet);
	return bullet;

func _ready():
	if life_time_in_seconds != 0:
		$Lifetime.wait_time = life_time_in_seconds
		$Lifetime.start()

func _process(delta):
	
	if current_fire_rate != fire_rate:
		current_fire_rate += 1
		return
	current_fire_rate = 0;
	
	 # All related to Bullet
	var computed_array_spread = compute_array_spread(total_bullet_arrays)
	var array_spread = computed_array_spread + deg2rad(bullet_array_starting_angle)
	for n in range (total_bullet_arrays):
		
		# Position Array
		if n > 0:
			array_spread = computed_array_spread * (n + 1)
		
		var computed_individual_spread = compute_individual_array_spread(bullets_per_array)
		var bullet_individual_spread = array_spread
		
		for m in range (bullets_per_array):
			
			# Alternating fire
			if alternating_fire == 1:
				if !((current_alternating_fire == 1 and m % 2 == 0) or (current_alternating_fire == 0 and m % 2 != 0)):
					continue
			
			# Position Bullet
			if m > 0:
				bullet_individual_spread = (computed_individual_spread * m) - array_spread
			
			# Creation of bullet
			var bullet = create_bullet();
			bullet.global_position = self.global_position;
			bullet.linear_velocity = Vector2(bullet_speed, 0).rotated(rotation - bullet_individual_spread)
			
	# Alternate odd/even
	if alternating_fire == 1:
		current_alternating_fire = 1 - current_alternating_fire
	
	# All related to Spin
	if spin_speed != 0:
		
		if spin_speed_rate != current_spin_speed_rate:
			current_spin_speed_rate += 1
		else:
			current_spin_speed_rate = 0
			
#			if spin_reversal == 1:
#				if self.rotation > deg2rad(max_spin_reversal * current_spin):
#					spin_speed *= -1
#					current_spin = 1 - current_spin
			
			self.rotate(deg2rad(spin_speed))
	pass

# Signals
func _on_Lifetime_timeout():
	queue_free()
	pass # Replace with function body.
