extends NinePatchRect


func _ready():
	Music.change_state("menu")


func _on_Button_pressed():
	Music.change_state("none")
	get_tree().change_scene("res://interiors/Housescene.tscn")


func _on_Button_mouse_entered():
	$MouseOver.play()

func apply_text_translation():
	$Button.set_text(tr(TranslationHub.KEYS.START))
