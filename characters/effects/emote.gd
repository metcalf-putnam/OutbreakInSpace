extends AnimatedSprite


func emote(type : String):
	match type:
		"happy":
			play("BeatingHeart")
			print(is_playing())
		"mad":
			play("grumbly")


func _on_Emote_animation_finished():
	play("default")
