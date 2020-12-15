extends NinePatchRect

signal is_pressed

var pressed := false
var mouse_over := false

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
	emit_signal("is_pressed")


func _on_Button_mouse_entered():
	$MouseOver.play()
	mouse_over = true


func _on_Button_mouse_exited():
	mouse_over = false
