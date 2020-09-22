extends Interactable
export (String, FILE, "*.tscn") var scene_path


func interact():
	.interact()
	if Global.energy >= 1:
		Global.decrement_energy()
	else:
		EventHub.emit_signal("insufficient_energy")
	assert(get_tree().change_scene(scene_path) == OK)
