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
	EventHub.connect("tv_interaction", self, "_on_tv_interaction")


func interact():
	EventHub.emit_signal("tv_dialogue", is_on)


func On():
	$AudioStreamPlayer.play()
	tv_anim.play("Tv")
	is_on = true
	var file_path = file_folder + str(Global.day) + ".json"
	yield(get_tree().create_timer(.5), "timeout")
	Global.tv_watched = true
	set_new_info(false)
	EventHub.emit_signal("new_dialogue", file_path, "TV Report")


func Off():
	tv_anim.stop()
	is_on = false
	$AudioStreamPlayer.play()

func _on_tv_interaction(option_text):
	match option_text:
		"On":
			On()
		"Off":
			Off()
	
