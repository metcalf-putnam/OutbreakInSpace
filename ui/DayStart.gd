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
		
	return health - (viral / infective_dose)


func update_characters_health():
	for data in Global.positive_characters:
		if data["id"] == CharacterManager.player_id:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"], 3000)
		else:
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"])


func set_test_status(id, status):
	if int(id) == CharacterManager.player_id:
		get_tree().root.get_node("Root/YSort/Player").data["done_test"] = status
	else:
		for npc in get_tree().root.get_node("Root/YSort/npcs").get_children():
			if int(id) == npc.data["id"]:
				npc.data["done_test"] = status


func get_id_from_result(result):
	var texts = result.split(" ")
	return texts[1]


func format_result(test_dic):
	var result_string = "ID: " + str(test_dic["data"]["id"]) + " - " + test_dic["data"]["name"] + ", "
	if test_dic["result"]:
		result_string = result_string + "positive"
	else:
		result_string = result_string + "negative"
	return result_string
