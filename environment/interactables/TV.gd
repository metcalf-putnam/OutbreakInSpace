extends Interactable

onready var tv_anim = $Sprite/AnimationPlayer
var is_on := false
var file_folder = "res://Dialog/json/tv/d"

func _ready():
	._ready()
	if !Global.tv_watched:
		set_new_info(true)
	else:
		set_new_info(false)


func interact():
	#EventHub.emit_signal("tv_dialogue", is_on)
	var file_path = file_folder + str(Global.day) + ".json"
	EventHub.emit_signal("new_dialogue", file_path, "TV Report")
	Global.tv_watched = true
	set_new_info(false)


func On():
	tv_anim.play("Tv")
	is_on = true


func Off():
	tv_anim.stop()
	is_on = false
