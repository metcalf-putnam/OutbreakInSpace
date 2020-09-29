extends Interactable

func _ready():
	._ready()
	check_status()
	EventHub.connect("dialogue_finished", self, "check_status")


func interact():
	EventHub.emit_signal("going_in_house_dialogue")


func check_status():
	if Global.energy <= 0:
		has_new_info = true
		$Exclamation.show()
	else:
		has_new_info = false
		$Exclamation.hide()

