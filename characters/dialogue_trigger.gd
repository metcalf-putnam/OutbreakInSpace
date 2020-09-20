extends Interactable
signal dialogue_started


func interact():
	.interact()
	emit_signal("dialogue_started")
