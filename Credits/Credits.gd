extends Node2D

var credits_finished = false

func _ready():
	Music.change_state("normal")

func _on_AnimationPlayer_animation_finished(anim_name):
	credits_finished = true
	$Continue.show()
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey and event.scancode == KEY_SPACE and credits_finished:
		get_tree().change_scene("res://menu/menu.tscn")
		
