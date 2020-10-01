extends CanvasLayer

var character_details_scn = preload("res://ui/CharacterDetails.tscn")

onready var scroll_container = $NinePatchRect/ScrollContainer
onready var list_container = $NinePatchRect/ScrollContainer/HBoxContainer
onready var nothing = $NinePatchRect/Nothing
onready var insufficient_energy = $NinePatchRect/InsufficientEnergy
onready var close = $NinePatchRect/Close_NinePatchRect
onready var auto_battle = $NinePatchRect/AutoBattle
onready var auto_battle_anim = $NinePatchRect/AutoBattle/AutoBattleAnimation

var character_data

func _ready():
	auto_battle.hide()
	nothing.hide()
	scroll_container.hide()
	scroll_container.get_h_scrollbar().connect("changed", self, "_on_scroll_change")
	if Global.player_settings.character_to_help_data != null:
		close.hide()
	show_positive_characters()


func show_positive_characters():
	
	if Global.positive_characters.size() == 0:
		nothing.show()
		return
	
	if Global.energy == 0:
		insufficient_energy.show()
	
	for data in Global.positive_characters:
		# Get character details
		var details = data
		
		# Create profile
		var character_details = character_details_scn.instance()
		character_details.connect("play_mini_game", self, "_on_play_mini_game")
		character_details.connect("auto_battle", self, "_on_auto_battle")
		character_details.connect("insufficient_energy", self, "_on_insufficient_energy")
		character_details.connect("health_update", self, "_on_health_update")
		list_container.add_child(character_details)
		character_details.init(details)
	
	scroll_container.show()

func _unhandled_input(event):
	if event is InputEventKey and close.visible:
		if event.scancode == KEY_SPACE:
			queue_free()


func _on_play_mini_game(data, game_mode):
	EventHub.emit_signal("start_mini_game", data, game_mode)
	queue_free()


func _on_auto_battle(data):
	character_data = data
	nothing.hide()
	scroll_container.hide()
	close.hide()
	Global.player_settings["is_skip"] = true
	auto_battle_anim.play("auto_battle")


func _on_AutoBattleAnimation_animation_finished(anim_name):
	if anim_name == "auto_battle":
		var additional_health = CharacterManager.get_additional_health(Global.player_settings)
		set_scroll_value(Global.positive_list_scroll_value)
		play_health_anim(additional_health)
		close.show()
		scroll_container.show()
		
		for n in list_container.get_children():
			n.check_buttons_availability()
		
		if Global.energy < 1:
			insufficient_energy.show()
	pass # Replace with function body.


func _on_insufficient_energy():
	insufficient_energy.show()


func set_scroll_value(value):
	scroll_container.get_h_scrollbar().value = value


func _on_scroll_change(value):
	Global.positive_list_scroll_value = value
	pass # Replace with function body.


func play_health_anim(additional_health, gnar_data = null):
	
	if gnar_data:
		character_data = gnar_data
	for positive in list_container.get_children():
		if positive.is_same_id(character_data["id"]):
			positive.play_add_health(additional_health)


func _on_health_update():
	close.show()

func _on_ScrollContainer_draw():
	scroll_container.get_h_scrollbar().value = Global.positive_list_scroll_value
	pass # Replace with function body.
