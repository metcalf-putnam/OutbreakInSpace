extends Sprite

onready var tween = $Tween

func pop():
	tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
