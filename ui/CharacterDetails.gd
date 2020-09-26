extends VBoxContainer

onready var character_name = $MarginContainer/VBoxContainer/Name
onready var health = $MarginContainer/VBoxContainer/Health
onready var status = $MarginContainer/VBoxContainer/Status
onready var select_btn = $MarginContainer/VBoxContainer/Button

signal play_mini_game
var data 
var character_id = 0

func init(data_in):
	data = data_in
	$MarginContainer/VBoxContainer/Name.text = "Name: " + data["name"]
	$MarginContainer/VBoxContainer/Health.text = "Health: " + str(data["health"])
	# TODO take path if data dictionary has "portrait_path",
	# else look up appropriate portrait based on race, etc.

func _on_Button_pressed():
	# TODO: Add details in this signal
	Global.player_settings.help_character_id = character_id
	emit_signal("play_mini_game", data)
