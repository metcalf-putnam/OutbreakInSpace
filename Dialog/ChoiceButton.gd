extends NinePatchRect
var pressed := false
var buffer := 17


func _ready():
	pass # Replace with function body.


func set_text(text_in):
	$Button.text = text_in
	rect_size.x = $Button.get_font("font").get_string_size(text_in).x + buffer


func get_text() -> String:
	return $Button.text


func _on_Button_pressed():
	pressed = true
