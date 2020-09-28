extends CanvasLayer
var report_title := "[wave]Daily Report[/wave]"
var new_infections_label := "New infections: "
var total_infections_label := "Total infections: "
var test_label := "[wave]Test Results:[/wave]"

func _ready():
	get_tree().paused = true
	var textbox = $NinePatchRect/RichTextLabel
	textbox.clear()
	textbox.append_bbcode(report_title) 
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode(new_infections_label + str(Global.new_infections))
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode(total_infections_label + str(Global.total_infections))
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode(test_label)
	if Global.test_results.has(Global.day):
		for test_dic in Global.test_results[Global.day]:
			if test_dic["result"]:
				if not Global.positive_characters.has(test_dic["data"]):
					Global.positive_characters.append(test_dic["data"])
			
			test_dic["data"]["done_test"] = false
			textbox.newline()
			textbox.append_bbcode(format_result(test_dic))
	else:
		textbox.append_bbcode("N/A")
		
	Global.new_infections = 0
	update_characters_health()
	check_new_positives()
	Global.player_position = Global.player_initial_position

func _input(event):
	if !event.is_action_pressed("ui_accept"):
		return
	get_tree().paused = false
	queue_free()


func compute_new_health(health, viral_load, infective_dose, cap = 0):
	var viral = viral_load
	if cap != 0 and viral_load > cap:
		viral = cap
	
	var status = CharacterManager.get_infective_dose_status(infective_dose)
	var base_drain = 1 # Moderate
	if status == "Severe":
		base_drain = 2
	elif status == "Critical":
		base_drain = 3
	
	print("base_drain: ", base_drain)
	var health_drain =  (viral / infective_dose) + base_drain
	print("health_drain: ", health_drain)
	return clamp(health - health_drain, 0, 100)


func update_characters_health():
	if CharacterManager.player["is_symptomatic"]:
		var data = CharacterManager.player
		var health = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])
		CharacterManager.player["health"] = health
	
	for data in CharacterManager.core_npcs:
		if data["is_symptomatic"]:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])
	
	for data in CharacterManager.npcs:
		if data["is_symptomatic"]:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])


func check_new_positives():
	for data in CharacterManager.core_npcs:
		if data["health"] < 50 and not Global.positive_characters.has(data):
			Global.positive_characters.append(data)
	
	for data in CharacterManager.npcs:
		if data["health"] < 50 and not Global.positive_characters.has(data):
			Global.positive_characters.append(data)


func set_test_status(id, status):
	if int(id) == CharacterManager.player_id:
		get_tree().root.get_node("Root/YSort/Player").data["done_test"] = status
	else:
		for npc in get_tree().root.get_node("Root/YSort/npcs").get_children():
			if int(id) == npc.data["id"]:
				npc.data["done_test"] = status


func format_result(test_dic):
	var result_string = "ID: " + str(test_dic["data"]["id"]) + " - " + test_dic["data"]["name"] + ", "
	if test_dic["result"]:
		result_string = result_string + "positive"
	else:
		result_string = result_string + "negative"
	return result_string
