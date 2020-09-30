extends CanvasLayer
const day_label = "Day "


func _ready():
	$PlayerControls.update_controls()
	$ColorRect.visible = true
	$ColorRect.modulate = Color(0,0,0,1)
	$DayCount.text = day_label + str(Global.day)
	Global.connect("fade_away_explanation", self, "_on_fade_away_explanation")


func fade_day():
	$AnimationPlayer.play("fade_to_black")
	Music.fade_current() 


func new_day():
	EventHub.emit_signal("day_ended")


func _on_Button_pressed():
	fade_day()


func _on_MaskButton_toggled(button_pressed):
	$Debug/MaskButton.release_focus()
	if button_pressed:
		get_tree().call_group("character", "mask_on")
	else:
		get_tree().call_group("character", "mask_off")


func _on_Visuals_Debug_toggled(button_pressed):
	$Debug/Visuals_Debug.release_focus()
	get_tree().call_group("character", "infection_visual", !button_pressed)
	Global.visuals_on = !button_pressed


func _on_fade_away_explanation():
	$AnimationPlayer.play("fade_away_explanation")
	
