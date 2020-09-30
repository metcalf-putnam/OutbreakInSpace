extends Node2D

func _ready():
	$Player.init(CharacterManager.player)
	$Player.deactivate_camaera()
	$Player.position = Vector2(107, 33)
	$Camera2D.zoom = Vector2(0.2, 0.2)
	
	EventHub.connect("tv_interaction", self, "_on_tv_interaction")
	EventHub.connect("bed_interaction", self, "_on_bed_interaction")
	EventHub.connect("computer_interaction", self, "_on_computer_interaction")
	EventHub.connect("pet_interaction", self, "_on_pet_interaction")
	$Player.speed = 50
	#$Overlay.disable_player_controls()  #for some reason this bugs out 
	# in the main scene if this is used in home scene


func _on_tv_interaction(status):
	if status == "On":
		$TV.On()
	elif status == "Off":
		$TV.Off()
	pass


func _on_bed_interaction():
	$Overlay.fade_day()
	pass


func _on_computer_interaction():
	var morning_report = preload("res://ui/DayStart.tscn").instance()
	get_tree().get_root().add_child(morning_report)
	pass


func _on_pet_interaction():
	print("pet")
	pass
