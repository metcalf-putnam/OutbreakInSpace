extends Area2D
class_name Interactable 

var player_in_range: Player = null
var has_new_info := true setget set_new_info
var is_interactable := true


func _ready():
	$Control.hide()
	

func _on_Interactable_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = body
		$Control.show()
		$Exclamation.hide()


func _on_Interactable_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = null
		$Control.hide()
		if has_new_info:
			$Exclamation.show()


func _unhandled_input(event):
	if event.is_action_pressed("ui_interact") \
		and player_in_range != null \
		and Global.active:
		
		if name != "Pet":
			player_in_range.in_dialogue()
		interact()  # only works if no other interactable in range, otherwise issues


func set_new_info(boolean):
	# TODO: ugh make this not horrible to read
	if boolean:
		$AnimationPlayer.play("blinking")
	elif !boolean and has_new_info:
		$AnimationPlayer.play("shrink")
	
	has_new_info = boolean


func interact():
	$Control.hide()
	set_new_info(false)
