extends TextureButton


func _on_TestButton_mouse_entered():
	$Hover.play()


func _on_TestButton_pressed():
	$Click.play()
