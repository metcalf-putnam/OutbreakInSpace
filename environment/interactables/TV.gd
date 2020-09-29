extends Interactable

onready var tv_anim = $Sprite/AnimationPlayer
var is_on := false

func _ready():
	._ready()
	if !Global.tv_watched:
		has_new_info = true
	else:
		has_new_info = false


func interact():
	EventHub.emit_signal("tv_dialogue", is_on)
	Global.tv_watched = true


func On():
	tv_anim.play("Tv")
	is_on = true

func Off():
	tv_anim.stop()
	is_on = false
