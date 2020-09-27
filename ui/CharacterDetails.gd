extends VBoxContainer

onready var portrait = $MarginContainer/VBoxContainer/Portrait
onready var character_name = $MarginContainer/VBoxContainer/Name
onready var health = $MarginContainer/VBoxContainer/Health
onready var viral_load = $MarginContainer/VBoxContainer/ViralLoad
onready var infective_dose = $MarginContainer/VBoxContainer/InfectiveDose
onready var health_reduction = $MarginContainer/VBoxContainer/HealthReductionPerDay
onready var select_btn = $MarginContainer/VBoxContainer/Button

signal play_mini_game
var data 
var character_id = 0

func init(data_in):
	data = data_in
	character_name.text = "Name: " + data["name"]
	var health_value = stepify(data["health"], 0.01)
	var health_percentage = (health_value / 100.0)
	
	health.text = "Health: " + str(health_value)
	
	var viralload = data["viral_load"]
	var infectivedose = data["infective_dose"]
	viral_load.text = "Viral Load: " + str(viralload)
	infective_dose.text = "Infective Dose: " + str(infectivedose)
	
	if data["id"] == 200 and viralload > 3000:
		viralload = 3000
	
	print(viralload, infectivedose)
	var reduction = stepify(viralload / infectivedose, 0.01)
	
	health_reduction.text = "Health Reduction / Day: " + str(reduction)
	
	portrait.self_modulate = Color(1.0, health_percentage, health_percentage, 1.0)
	if data["portrait_path"] != "":
		portrait.set_texture(load(data["portrait_path"]))
	else:
		portrait.set_texture(load("res://characters/portraits/portrait_blue_man.png"))
	
	# TODO take path if data dictionary has "portrait_path",
	# else look up appropriate portrait based on race, etc.

func _on_Button_pressed():
	emit_signal("play_mini_game", data)
