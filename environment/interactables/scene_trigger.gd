extends Interactable
export (String, FILE, "*.tscn") var scene_path


func interact():
	.interact()
	assert(get_tree().change_scene(scene_path) == OK)
