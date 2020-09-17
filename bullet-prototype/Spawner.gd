extends Node2D

var bullet_scn = preload("res://bullet-prototype/Bullet.tscn")

var total_bullet_arrays = 2
var total_array_spread = 90

var bullets_per_array = 3
var individual_array_spread = 90

var spin_speed = 0 # positive = counter clock wise, negative = clock wise
var spin_speed_rate = 0
var current_spin_speed_rate = 0

var fire_rate = 4
var alternating_fire = 0 # 0 or 1 = on or off
var current_alternating_fire = 0 # 0 = odd or 1 = even
var current_rate = 0
var bullet_speed = 350

var object_width = 0
var object_height = 0
var x_offset = 0
var y_offset = 0


func compute_array_spread(total):
	if total == 1: return 0;
	
	return deg2rad(total_array_spread / (total - 1))

func compute_individual_array_spread(total):
	if total == 1: return 0;
	
	return deg2rad(individual_array_spread / (total - 1))

func create_bullet():
	var bullet = bullet_scn.instance();
	get_tree().get_root().add_child(bullet);
	return bullet;

func _ready():
	pass # Replace with function body.

func _process(delta):
	
	if current_rate != fire_rate:
		current_rate += 1
		return
	current_rate = 0;
	
	 # All related to Bullet
	var computed_array_spread = compute_array_spread(total_bullet_arrays)
	var array_spread = 0
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
			self.rotate(deg2rad(spin_speed))
	pass
