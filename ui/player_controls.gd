extends VBoxContainer


func _ready():
	show_glow(false)
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("new_dialogue", self, "_on_new_dialogue")
	EventHub.connect("testing_character", self, "_on_testing_character")
	EventHub.connect("bed_dialogue", self, "_on_new_door_dialogue")
	EventHub.connect("tv_dialogue", self, "_on_new_dialogue")
	EventHub.connect("going_in_house_dialogue", self, "_on_new_door_dialogue")
	EventHub.connect("going_out_house_dialogue", self, "_on_new_door_dialogue")
	check_new_reports()
	EventHub.connect("no_testables_in_range", self, "_on_no_testables_in_range")
	EventHub.connect("testable_character_in_range", self, "_on_testable_character_in_range")


func _on_no_testables_in_range():
	show_glow(false)


func _on_testable_character_in_range():
	show_glow(true)


func show_glow(boolean):
	if boolean:
		if !$AnimationPlayer.current_animation == "test_glow_on":
			$TestActivation.play()
			$AnimationPlayer.play("test_glow_on")
	else:
		$AnimationPlayer.play("test_glow_off")


func _on_dialogue_finished():
	update_controls()
	show()


func _on_new_dialogue(_file, _name = null, _portrait = null):
	hide()


func _on_new_door_dialogue():
	hide()
	

func _on_testing_character(_characters, _name = null):
	print("inside testing character")
	hide()


func _on_TestButton_pressed():
	$TestButton.release_focus()
	if $SingButton.pressed or Input.is_action_pressed("ui_accept"):
		return
	EventHub.emit_signal("test_button_pressed")
	show_glow(true)


func update_controls():
	if Global.player_can_sing:
		$SingButton.show()
	else:
		$SingButton.hide()
	
	if Global.player_can_test:
		$TestButton.show()
	else:
		$TestButton.hide()
		
	check_new_reports()


func _on_ReportButton_pressed():
	$ReportButton.release_focus()
	EventHub.emit_signal("computer_interaction")
	Global.report_read = true
	hide()


func _on_SingButton_button_down():
	EventHub.emit_signal("sing_button_pressed")


func _on_SingButton_button_up():
	EventHub.emit_signal("sing_button_released")
	Global.songs_sung += 1
	$SingButton.release_focus()


func check_new_reports():
	if Global.report_read:
		$ReportButton/Sprite.hide()
	else:
		$ReportButton/Sprite.show()
	
