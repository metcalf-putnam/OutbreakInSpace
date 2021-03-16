extends Interactable


func _ready():
	set_new_info(false)
	$Emote.play("default")


func interact():
	$Emote.emote("happy")
	$AudioStreamPlayer.play()
	$Control.hide()
	Logger.create_log_for("Pet", Logger.LOG_TYPE.PET_INTERACTION)
	Global.pets_given += 1
