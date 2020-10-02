extends Node2D
export(String, FILE, "*.json") var failure_dialog_file
export(String, FILE, "*.json") var success_dialog_file
var bad_ending := false
onready var textbox = $RichTextLabel
var good_ending_text = "On the 11th of Jeha, Lord Aso arrived for the festival"
var bad_ending_text = "On the 11th of Jeha..........the festival was canceled.........."
var good_modulate = Color(0.64, 0.79, 0.61, 0.84)
var bad_modulate = Color(0.56, 0.52, 0.52, 0.84)


func _ready():
	determine_ending()
	populate_stats()
	Global.connect("overlord_discovery", self, "_on_overlord_discovery")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	$AnimationPlayer.play("opening")
	$Sprite.hide()
	$TextureButton.hide()


func start_overlord_dialogue():
	if bad_ending:
		EventHub.emit_signal("new_dialogue", failure_dialog_file, "???")
	else:
		EventHub.emit_signal("new_dialogue", success_dialog_file, "Overlord Aso")
		$VictoryLoop.play()
	$RichTextLabel.hide()


func _on_overlord_discovery():
	$Dialogue.update_name("Overlord Aso")
	$Sprite.show()


func _on_dialogue_finished():
	if bad_ending:
		Global.restart_game(bad_ending) # overlord options on
	else:
		get_tree().change_scene("res://Credits.tscn")


func determine_ending():
	if Global.total_infections < 5 and Global.dead_characters.size() > 0:
		bad_ending = false
		$VictorySound.play()
		textbox.append_bbcode(good_ending_text)
		$ColorRect.modulate = good_modulate
	else:
		$FailureAmbiance.play()
		bad_ending = true
		textbox.append_bbcode(bad_ending_text)
		$ColorRect.modulate = bad_modulate


func populate_stats():
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode("Stats:")
	add_formatted_stat("population", 86)
	add_formatted_stat("infections", Global.total_infections)
	add_formatted_stat("deaths", Global.dead_characters.size())
	add_formatted_stat("songs sung", Global.songs_sung)
	add_formatted_stat("conversations had", Global.conversations_had)
	add_formatted_stat("cookies eaten", Global.cookies)


func add_formatted_stat(name, value):
	textbox.newline()
	textbox.append_bbcode(name + ": " + str(value))


func _on_AnimationPlayer_animation_finished(anim_name):
	$TextureButton.show()


func _on_TextureButton_pressed():
	start_overlord_dialogue()
	$TextureButton.hide()
