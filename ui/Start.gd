extends NinePatchRect


func _ready():
	Music.change_state("menu")


func _on_Button_pressed():
	get_tree().change_scene("res://interiors/Housescene.tscn")


func _on_Button_mouse_entered():
	$MouseOver.play()
