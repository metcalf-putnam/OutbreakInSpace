extends HBoxContainer


func _ready():
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("new_dialogue", self, "_on_new_dialogue")
	EventHub.connect("testing_character", self, "_on_testing_character")
	EventHub.connect("bed_dialogue", self, "_on_new_dialogue")
	EventHub.connect("tv_dialogue", self, "_on_new_dialogue")
	EventHub.connect("going_in_house_dialogue", self, "_on_new_door_dialogue")
	EventHub.connect("going_out_house_dialogue", self, "_on_new_door_dialogue")


func _on_dialogue_finished():
	update_controls()
	show()


func _on_new_dialogue(_file, _name):
	hide()


func _on_new_door_dialogue():
	hide()
	

func _on_testing_character(_characters):
	print("inside testing character")
	hide()


func _on_TestButton_pressed():
	$TestButton.release_focus()
	if $SingButton.pressed or Input.is_action_pressed("ui_accept"):
		return
	EventHub.emit_signal("test_button_pressed")


func update_controls():
	if Global.player_can_sing:
		$SingButton.show()
	else:
		$SingButton.hide()
	
	if Global.player_can_test:
		$TestButton.show()
	else:
		$TestButton.hide()


func _on_ReportButton_pressed():
	print("report pressed!")
	$ReportButton.release_focus()
	EventHub.emit_signal("computer_interaction")


func _on_SingButton_button_down():
	EventHub.emit_signal("sing_button_pressed")


func _on_SingButton_button_up():
	EventHub.emit_signal("sing_button_released")
	$SingButton.release_focus()
	
