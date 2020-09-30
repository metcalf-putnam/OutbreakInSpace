extends Node2D
export(String, FILE, "*.json") var failure_dialog_file

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("overlord_discovery", self, "_on_overlord_discovery")
	$AnimationPlayer.play("opening")
	$Sprite.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "opening":
		EventHub.emit_signal("new_dialogue", failure_dialog_file, "???")
		$RichTextLabel.hide()

func _on_overlord_discovery():
	$Dialogue.update_name("Overlord Aso")
	$Sprite.show()
	
