extends Interactable


func _ready():
	set_new_info(false)
	$Emote.play("default")


func interact():
	$Emote.emote("happy")
	$AudioStreamPlayer.play()
	$Control.hide()
