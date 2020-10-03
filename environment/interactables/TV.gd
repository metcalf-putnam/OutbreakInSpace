extends Interactable

onready var tv_anim = $Sprite
var is_on := false
var file_folder = "res://Dialog/json/tv/d"
var anim

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
	tv_anim.play("turn_on")
	anim = "turn_on"
	is_on = true


func Off():
	tv_anim.play("turn_off")
	anim = "turn_off"
	is_on = false
	$AudioStreamPlayer.play()


func _on_tv_interaction(option_text):
	match option_text:
		"On":
			On()
		"Off":
			Off()


func _on_Sprite_animation_finished():
	if !anim:
		return
	match anim:
		"turn_on":
			tv_anim.play("on")
			anim = "on"
			watch_tv()
		"turn_off":
			tv_anim.play("off")
			anim = "off"
			
func watch_tv():
	var file_path = file_folder + str(Global.day) + ".json"
	Global.tv_watched = true
	EventHub.emit_signal("new_dialogue", file_path, "TV Report")
	set_new_info(false)
