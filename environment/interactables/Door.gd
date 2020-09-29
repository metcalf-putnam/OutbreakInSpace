extends Interactable

func _ready():
	._ready()
	has_new_info = false
	$Exclamation.hide()

func interact():
	EventHub.emit_signal("going_out_house_dialogue")