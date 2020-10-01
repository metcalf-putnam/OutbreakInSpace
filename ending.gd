extends Node2D
export(String, FILE, "*.json") var failure_dialog_file
export(String, FILE, "*.json") var success_dialog_file
var bad_ending := true


func _ready():
	determine_ending()
	Global.connect("overlord_discovery", self, "_on_overlord_discovery")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	$AnimationPlayer.play("opening")
	$Sprite.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "opening":
		return
	if bad_ending:
		EventHub.emit_signal("new_dialogue", failure_dialog_file, "???")
	else:
		EventHub.emit_signal("new_dialogue", success_dialog_file, "Overlord Aso")

	$RichTextLabel.hide()


func _on_overlord_discovery():
	$Dialogue.update_name("Overlord Aso")
	$Sprite.show()


func _on_dialogue_finished():
		Global.restart_game(bad_ending)


func determine_ending():
	if Global.total_infections < 5 and Global.dead_characters.size() > 0:
		bad_ending = false
