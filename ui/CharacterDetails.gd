extends VBoxContainer

onready var character_name = $MarginContainer/VBoxContainer/Name
onready var health = $MarginContainer/VBoxContainer/Health
onready var status = $MarginContainer/VBoxContainer/Status
onready var select_btn = $MarginContainer/VBoxContainer/Button

signal play_mini_game

var character_id = 0

func init(data, path):
	character_id = data["id"]
	character_name.text = "Name: " + data["name"]
	health.text = "Health: " + str(data["health"])


func _on_Button_pressed():
	# TODO: Add details in this signal
	Global.player_settings.help_character_id = character_id
	emit_signal("play_mini_game", {})
	pass # Replace with function body.
