extends Area2D
class_name Interactable 

var player_in_range := false
var has_new_info := true setget set_new_info
var is_interactable := true


func _on_Interactable_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true


func _on_Interactable_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


func _unhandled_input(event):
	if event.is_action_pressed("ui_interact") and player_in_range:
		interact()  # only works if no other interactable in range, otherwise issues


func set_new_info(boolean):
	has_new_info = boolean
	if has_new_info:
		$Exclamation.visible = true
	else:
		$Exclamation.visible = false


func interact():
	print("interacting!")
	set_new_info(false)
