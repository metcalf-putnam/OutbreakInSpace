extends Interactable


func _ready():
	._ready()
	if !Global.report_read:
		has_new_info = true
	else:
		has_new_info = false


func interact():
	EventHub.emit_signal("computer_dialogue")
	Global.report_read = true
	set_new_info(false)
