extends Interactable
export (String, FILE, "*.tscn") var scene_path


func interact():
	.interact()
	if Global.energy >= 1:
		Global.decrement_energy()
		Global.player_position = global_position + Vector2(0, 10)
		assert(get_tree().change_scene(scene_path) == OK)
	else:
		EventHub.emit_signal("insufficient_energy")

