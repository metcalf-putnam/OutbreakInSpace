extends AnimatedSprite


func emote(type : String):
	match type:
		"happy":
			play("BeatingHeart")
		"mad":
			play("grumbly")
