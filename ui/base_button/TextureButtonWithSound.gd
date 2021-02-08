extends TextureButton


func _on_TextureButton_pressed():
	$Press.play()


func _on_TextureButton_mouse_entered():
	$Hover.play()
