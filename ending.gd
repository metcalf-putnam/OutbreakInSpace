extends Node2D
export(String, FILE, "*.json") var failure_dialog_file
var good_ending := false


func _ready():
	determine_ending()
	Global.connect("overlord_discovery", self, "_on_overlord_discovery")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	$AnimationPlayer.play("opening")
	$Sprite.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "opening":
		EventHub.emit_signal("new_dialogue", failure_dialog_file, "???")
		$RichTextLabel.hide()


func _on_overlord_discovery():
	$Dialogue.update_name("Overlord Aso")
	$Sprite.show()


func _on_dialogue_finished():
	Global.debug_on = true
	assert(get_tree().change_scene("res://interiors/Housescene.tscn") == OK)


func determine_ending():
	pass
