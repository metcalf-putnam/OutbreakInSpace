extends Interactable

func _ready():
	._ready()
	$Exclamation.hide()
	if Global.energy <= 0:
		has_new_info = true
	else:
		has_new_info = false

func interact():
	EventHub.emit_signal("bed_dialogue")
