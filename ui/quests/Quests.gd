extends CanvasLayer
var completed_modulate = Color(0.58, 0.58, 0.58)
var full_size = 225
var mid_size = 137
var collapsed_size = 46
var all_quests := false


func _ready():
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	update_quests()


func _on_TextureButton_toggled(button_pressed):
	if button_pressed:
		$Label/List.hide()
		$Label/TextureButton/Label.text = "show"
	else:
		$Label/List.show()
		$Label/TextureButton/Label.text = "hide"
	update_nine_patch()


func update_quests():
	if !Global.first_lab_visit and Global.player_can_test:
		$Label.show()
		$NinePatchRect.show()
	else:
		$Label.hide()
		$NinePatchRect.hide()
		return
		
	if Global.idk_quests:
		all_quests = true
		$Label/List/IdkQuest1.show()
		$Label/List/IdkQuest2.show()
		$Label/List/IdkQuest3.show()
	else:
		all_quests = false
		$Label/List/IdkQuest1.hide()
		$Label/List/IdkQuest2.hide()
		$Label/List/IdkQuest3.hide()
		
	$Label/List/TestingQuest/Status.bbcode_text = "(" + str(Global.d1s_tested) + "/8)" 
	if Global.d1s_tested == 8:
		strikeout_quest($Label/List/TestingQuest)
	if Global.player_helmet:
		strikeout_quest($Label/List/HelmetQuest)
	$Label/List/ConvinceQuest/Status.bbcode_text = "(" + str(Global.npcs_convinced) + "/3)"
	if Global.npcs_convinced >= 3:
		strikeout_quest($Label/List/ConvinceQuest)
	
	update_nine_patch()


func _on_dialogue_finished():
	update_quests()


func update_nine_patch():
	if $Label/TextureButton.pressed:
		$NinePatchRect.rect_size.y = collapsed_size
	else:
		if all_quests:
			$NinePatchRect.rect_size.y = full_size
		else:
			$NinePatchRect.rect_size.y = mid_size


func strikeout_quest(node):
	node.get_child(0).bbcode_text = "[s]" + node.get_child(0).bbcode_text + "[/s]"
	node.modulate = completed_modulate
	if node.get_child_count() > 1:
		node.get_child(1).bbcode_text = "[s]" + node.get_child(1).bbcode_text + "[/s]"
