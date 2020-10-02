extends NinePatchRect
var completed_modulate = Color(0.58, 0.58, 0.58)
var full_size = 387
var mid_size = 137
var collapsed_size = 46
var all_quests := false


func _ready():
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	update_quests()


func _on_TextureButton_toggled(button_pressed):
	$Label/TextureButton.release_focus()
	if button_pressed:
		$List.hide()
		$Label/TextureButton/Label.text = "show"
	else:
		$List.show()
		$Label/TextureButton/Label.text = "hide"
	update_nine_patch()


func update_quests():
	if !Global.first_lab_visit and Global.player_can_test:
		show()
	else:
		hide()
		return
		
	if Global.idk_quests:
		all_quests = true
		$List/idkQuests.show()
	else:
		all_quests = false
		$List/idkQuests.hide()
		
	$List/TestingQuest/Status.bbcode_text = "(" + str(min(Global.d1s_tested, 8)) + "/8)" 
	if Global.d1s_tested >= 8:
		strikeout_quest($List/TestingQuest)
		Global.testing_completed = true
	if Global.player_helmet:
		strikeout_quest($List/HelmetQuest)
	$List/ConvinceQuest/Status.bbcode_text = "(" + str(min(Global.npcs_convinced, 3)) + "/3)"
	if Global.npcs_convinced >= 3:
		strikeout_quest($List/ConvinceQuest)
	
	update_nine_patch()


func _on_dialogue_finished():
	update_quests()


func update_nine_patch():
	if $Label/TextureButton.pressed:
		rect_size.y = collapsed_size
	else:
		if all_quests:
			rect_size.y = full_size
		else:
			rect_size.y = mid_size


func strikeout_quest(node):
	node.get_child(0).bbcode_text = "[s]" + node.get_child(0).bbcode_text + "[/s]"
	node.modulate = completed_modulate
	if node.get_child_count() > 1:
		node.get_child(1).bbcode_text = "[s]" + node.get_child(1).bbcode_text + "[/s]"
