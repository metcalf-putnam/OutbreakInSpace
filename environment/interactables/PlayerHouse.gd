extends Interactable

func _ready():
	._ready()
	$Exclamation.hide()

func interact():
	EventHub.emit_signal("going_in_house_dialogue")
	pass
	