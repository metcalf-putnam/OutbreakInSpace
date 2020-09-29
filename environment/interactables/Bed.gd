extends Interactable

func _ready():
	._ready()
	$Exclamation.hide()

func interact():
	EventHub.emit_signal("bed_dialogue")