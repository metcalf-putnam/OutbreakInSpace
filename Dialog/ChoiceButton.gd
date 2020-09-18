extends NinePatchRect
var pressed := false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func set_text(text_in):
	$Button.text = text_in


func _on_Button_pressed():
	pressed = true
