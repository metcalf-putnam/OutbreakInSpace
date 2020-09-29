extends VBoxContainer

onready var portrait = $MarginContainer/VBoxContainer/Portrait
onready var character_name = $MarginContainer/VBoxContainer/Name
onready var health = $MarginContainer/VBoxContainer/Health
onready var status = $MarginContainer/VBoxContainer/Status
onready var health_reduction = $MarginContainer/VBoxContainer/HealthReductionPerDay
onready var select_btn = $MarginContainer/VBoxContainer/Button
onready var auto_battle_btn = $MarginContainer/VBoxContainer/AutoBattle

signal play_mini_game
signal auto_battle
signal insufficient_energy
var data
var game_mode
var character_id = 0

func init(data_in):	
	data = data_in
	
	character_name.text = "Name: " + data["name"]
	var health_value = stepify(data["health"], 0.01)
	var health_percentage = (health_value / 100.0)
	
	var dose_status = CharacterManager.get_infective_dose_status(data)
	if health_value == 0:
		dose_status = "Dead"
	health.text = "Health: " + str(health_value)
	status.text = "Status: " + dose_status
	
	if dose_status == "Moderate":
		game_mode = "EASY"
	elif dose_status == "Severe":
		game_mode = "MEDIUM"
	else:
		game_mode = "HARD"
	
	var viralload = data["viral_load"]
	var infectivedose = data["infective_dose"]
	if data["id"] == 200 and viralload > 3000:
		viralload = 3000
	
	var reduction = stepify(viralload / infectivedose, 0.01)
	
	var base_drain = 1 # Moderate
	if dose_status == "Severe":
		base_drain = 2
	elif dose_status == "Critical":
		base_drain = 3
	reduction += base_drain
	
	if dose_status == "Dead":
		reduction = 0
	health_reduction.text = "Health Reduction / Day: " + str(reduction)
	
	portrait.self_modulate = Color(1.0, health_percentage, health_percentage, 1.0)
	if data["portrait_path"] != "":
		portrait.set_texture(load(data["portrait_path"]))
	else:
		var type = data["type"]
		var race = data["race"]
		var portrait_path = "res://characters/portraits/" + race + type + ".png"
		if ResourceLoader.exists(portrait_path):
			portrait.set_texture(load(portrait_path))
		else:
			portrait.set_texture(load("res://characters/portraits/portrait_blue_man.png"))
	
	if Global.energy < 1 or dose_status == "Dead":
		select_btn.hide()
		auto_battle_btn.hide()


func _on_Button_pressed():
	emit_signal("play_mini_game", data, game_mode)


func _on_AutoBattle_pressed():
	if Global.energy >= 1:
		Global.decrement_energy()
		emit_signal("auto_battle", data)
	else:
		emit_signal("insufficient_energy")
	pass # Replace with function body.
