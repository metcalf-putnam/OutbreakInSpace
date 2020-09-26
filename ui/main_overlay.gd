extends CanvasLayer
const day_label = "Day "

func _ready():
	$ColorRect.visible = true
	$ColorRect.modulate = Color(0,0,0,1)
	$DayCount.text = day_label + str(Global.day)


func new_day():
	EventHub.emit_signal("day_ended")


func _on_Button_pressed():
	$AnimationPlayer.play("fade_to_black")


func _on_MaskButton_toggled(button_pressed):
	$Debug/MaskButton.release_focus()
	if button_pressed:
		get_tree().call_group("character", "mask_on")
	else:
		get_tree().call_group("character", "mask_off")


func _on_Visuals_Debug_toggled(button_pressed):
	get_tree().call_group("character", "infection_visual", button_pressed)
