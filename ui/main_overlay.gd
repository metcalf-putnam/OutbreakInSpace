extends CanvasLayer
const day_label = "Day "


func _ready():
	if Global.debug_on:
		$Debug.show()
	else:
		$Debug.hide()
	if Global.day > 1:
		$PlayerControls/ReportButton.show()
	else:
		$PlayerControls/ReportButton.hide()
	
	if Global.energy > 0:
		$DaysBackground/Energy/EndDayButton.hide()
	else:
		$DaysBackground/Energy/EndDayButton.show()
		
	$PlayerControls.update_controls()
	$ColorRect.visible = true
	$ColorRect.modulate = Color(0,0,0,1)
	$DaysBackground/DayCount.text = day_label + str(Global.day)
	Global.connect("fade_away_explanation", self, "_on_fade_away_explanation")


func fade_day():
	$AnimationPlayer.play("fade_to_black")
	Music.fade_current() 


func new_day():
	EventHub.emit_signal("day_ended")


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


func player_controls_toggle(boolean):
	if boolean:
		$PlayerControls.hide()
	else:
		$PlayerControls.show()


func _on_Dialogue_player_controls_toggle(boolean):
	player_controls_toggle(boolean)


func show_end_day_button():
	$DaysBackground/Energy/EndDayButton.show()


func _on_NoEnergyPopup_show_end_day():
	$DaysBackground/Energy/EndDayButton.show()
	Global.no_more_energy = true


func _on_NoEnergyPopup_player_controls_toggle(boolean):
	player_controls_toggle(boolean)


func _on_EndDayButton_pressed():
	fade_day()
	pass # Replace with function body.
