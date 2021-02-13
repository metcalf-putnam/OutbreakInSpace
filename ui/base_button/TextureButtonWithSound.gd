extends TextureButton
export (Resource) var hover_stream
export (Resource) var press_stream

func _ready():
	if hover_stream:
		$Hover.stream = hover_stream
	
	if press_stream:
		$Press.stream = press_stream


func _on_TextureButton_pressed():
	$Press.play()


func _on_TextureButton_mouse_entered():
	$Hover.play()
