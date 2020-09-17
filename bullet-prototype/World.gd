extends Node2D

func LoadControls():
	$Control/VBoxContainer/BulletPerArrayContainer/BulletsPerArray.text = "bullets per array: " + str($Spawner.bullets_per_array)
	$Control/VBoxContainer/IndividualArraySpreadContainer/IndividualArraySpread.text = "individual array spread: " + str($Spawner.individual_array_spread)
	$Control/VBoxContainer/TotalBulletArrayContainer/TotalBulletArrays.text = "total bullet arrays: " + str($Spawner.total_bullet_arrays)
	$Control/VBoxContainer/TotalArraySpreadContainer/TotalArraySpread.text = "total array spread: " + str($Spawner.total_array_spread)
	$Control/VBoxContainer/SpinSpeedContainer/SpinSpeed.text = "spin speed: " + str($Spawner.spin_speed)
	$Control/VBoxContainer/SpinSpeedRateContainer/SpinSpeedRate.text = "spin speed rate: " + str($Spawner.spin_speed_rate)
	$Control/VBoxContainer/FireRateContainer/FireRate.text = "fire rate: " + str($Spawner.fire_rate)
	$Control/VBoxContainer/BulletSpeedContainer/BulletSpeed.text = "bullet speed: " + str($Spawner.bullet_speed)
	$Control/VBoxContainer/AlternatingFireContainer/AlternatingFire.text = "alternating fire: " + str($Spawner.alternating_fire)
# Called when the node enters the scene tree for the first time.
func _ready():
	LoadControls()
	pass # Replace with function body.

func _on_AddBullet_pressed():
	$Spawner.bullets_per_array += 1
	LoadControls()
	pass # Replace with function body.

func _on_MinusBullet_pressed():
	if $Spawner.bullets_per_array > 1:
		$Spawner.bullets_per_array -= 1
		LoadControls()
	pass # Replace with function body.

func _on_IncrementIndividualArraySpread_pressed():
	$Spawner.individual_array_spread += 5
	LoadControls()
	pass # Replace with function body.

func _on_DecrementIndividualArraySpread_pressed():
	$Spawner.individual_array_spread -= 5
	LoadControls()
	pass # Replace with function body.

func _on_AddBulletArray_pressed():
	$Spawner.total_bullet_arrays += 1
	LoadControls()
	pass # Replace with function body.

func _on_MinusBulletArray_pressed():
	$Spawner.total_bullet_arrays -= 1
	LoadControls()
	pass # Replace with function body.

func _on_IncrementTotalArraySpread_pressed():
	$Spawner.total_array_spread += 5
	LoadControls()
	pass # Replace with function body.

func _on_DecrementTotalArraySpread_pressed():
	$Spawner.total_array_spread -= 5
	LoadControls()
	pass # Replace with function body.

func _on_IncrementSpinSpeed_pressed():
	$Spawner.spin_speed += 1
	LoadControls()
	pass # Replace with function body.

func _on_DecrementSpinSpeed_pressed():
	$Spawner.spin_speed -= 1
	LoadControls()
	pass # Replace with function body.

func _on_IncremenSpinSpeedRate_pressed():
	$Spawner.spin_speed_rate += 1
	LoadControls()
	pass # Replace with function body.

func _on_DecremenSpinSpeedRate_pressed():
	if $Spawner.spin_speed_rate > 0:
		$Spawner.spin_speed_rate -= 1
		LoadControls()
	pass # Replace with function body.

func _on_IncremenFireRate_pressed():
	$Spawner.fire_rate += 1
	LoadControls()
	pass # Replace with function body.

func _on_DecremenFireRate_pressed():
	if $Spawner.fire_rate > 0:
		$Spawner.fire_rate -= 1
		LoadControls()
	pass # Replace with function body.

func _on_IncremenBulletSpeed_pressed():
	$Spawner.bullet_speed += 5
	LoadControls()
	pass # Replace with function body.

func _on_DecremenBulletSpeed_pressed():
	$Spawner.bullet_speed -= 5
	LoadControls()
	pass # Replace with function body.

func _on_AlternatingFireOnOff_pressed():
	$Spawner.alternating_fire = 1 - $Spawner.alternating_fire
	LoadControls()
	pass # Replace with function body.
