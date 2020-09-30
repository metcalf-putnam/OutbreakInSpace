extends Node2D
export(String, FILE, "*.json") var failure_dialog_file
var bad_ending := true


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
		Global.restart_game(bad_ending)


func determine_ending():
	pass
	# TODO: fill this in
