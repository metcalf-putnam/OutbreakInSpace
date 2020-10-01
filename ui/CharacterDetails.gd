extends VBoxContainer

onready var portrait = $MarginContainer/VBoxContainer/Portrait
onready var character_name = $MarginContainer/VBoxContainer/Name
onready var health = $MarginContainer/VBoxContainer/Health
onready var status = $MarginContainer/VBoxContainer/Status
onready var health_reduction = $MarginContainer/VBoxContainer/HealthReductionPerDay
onready var select_btn = $MarginContainer/VBoxContainer/Button
onready var auto_battle_btn = $MarginContainer/VBoxContainer/AutoBattle
onready var additional_health = $MarginContainer/VBoxContainer/Health/AddValue
onready var health_anim = $MarginContainer/VBoxContainer/HealthAnimation

signal play_mini_game
signal auto_battle
signal insufficient_energy
signal health_update
var data
var game_mode
var character_id = 0
var add_health = 0

func init(data_in):	
	data = data_in
	
	character_name.text = data["name"]
	character_id = data["id"]
	var health_value = stepify(data["health"], 0.01)
	var health_percentage = (health_value / 100.0)
	
	var dose_status = CharacterManager.get_infective_dose_status(data)
	if health_value == 0:
		dose_status = "Dead"
	elif health_value == 100:
		dose_status = "Asymptomatic"
		
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
	
	health_reduction.text = "Minus Health / Day: " + str(reduction)
	
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
	
	if Global.energy < 1 or dose_status in ["Dead", "Asymptomatic"]:
		if dose_status in ["Dead", "Asymptomatic"]:
			health_reduction.modulate.a = 0
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


func is_same_id(id):
	return character_id == id


func play_add_health(to_add_health):
	add_health = to_add_health
	additional_health.text = "+" + str(add_health) + " Health"
	health_anim.play("show_additional_health")


func _on_HealthAnimation_animation_finished(anim_name):
	if anim_name == "show_additional_health":
		var health_value = float(health.text.split(" ")[1])
		var new_health = stepify(float(health_value + add_health), 0.01)
		print(health.text, " ", health_value, " ", new_health)
		health.text = "Health: " + str(new_health)
		CharacterManager.update_character_health(data, add_health)
		emit_signal("health_update")
	pass # Replace with function body.


func check_buttons_availability():
	if Global.energy < 1:
		select_btn.hide()
		auto_battle_btn.hide()