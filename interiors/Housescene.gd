extends Node2D

func _ready():
	Music.change_state("none")
	$AudioStreamPlayer.play()
	$Player.init(CharacterManager.player)
	$Player.deactivate_camaera()
	$Player.position = Vector2(107, 33)
	
	EventHub.connect("tv_interaction", self, "_on_tv_interaction")
	EventHub.connect("bed_interaction", self, "_on_bed_interaction")
	EventHub.connect("computer_interaction", self, "_on_computer_interaction")
	EventHub.connect("pet_interaction", self, "_on_pet_interaction")


	$Player.speed = 50
	
	
	if not Global.day_transitioned:
		$DayTransition.show_transition()
	else:
		$CanvasLayer/LogScreen.visible = true
		
	$DayTransition.connect("day_transitioned", self, "_on_day_transitioned")


func _on_tv_interaction(status):
	if status == "On":
		$TV.On()
	elif status == "Off":
		$TV.Off()


func _on_bed_interaction():
	$Overlay.fade_day()


func _on_computer_interaction():
	var morning_report = preload("res://ui/DayStart.tscn").instance()
	get_tree().get_root().add_child(morning_report)


func _on_pet_interaction():
	print("pet")

func _on_day_transitioned():
	$CanvasLayer/LogScreen.visible = true

