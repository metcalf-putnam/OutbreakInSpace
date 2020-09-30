extends AnimatedSprite


func emote(type : String):
	match type:
		"happy":
			play("BeatingHeart")
		"mad":
			play("grumbly")


func _on_Emote_animation_finished():
	play("default")
