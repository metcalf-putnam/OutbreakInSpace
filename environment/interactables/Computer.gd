extends Interactable

func _ready():
	._ready()

func interact():
	EventHub.emit_signal("computer_dialogue")