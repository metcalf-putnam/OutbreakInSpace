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
		for result in Global.test_results[Global.day]:
			
			var id = get_id_from_result(result)
			# add the character to list of positives in day report
			if result.ends_with("positive"):
				if not Global.positive_ids.has(id):
					Global.positive_ids.append(id)
			set_test_status(id, false)
			textbox.newline()
			textbox.append_bbcode(result)
	else:
		textbox.append_bbcode("N/A")
		
	Global.new_infections = 0
	update_characters_health()

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
	for id in Global.positive_ids:
		if int(id) == CharacterManager.player_id:
			var player_node = get_tree().root.get_node("Root/YSort/Player")
			var data = player_node.data
			data["health"] = compute_new_health(data["health"], data["viral_load"], data["infective_dose"], 3000)
		else:
			var npcs_node = get_tree().root.get_node("Root/YSort/npcs")
			for npc in npcs_node.get_children():
				if int(id) == npc.data["id"]:
					var data = npc.data
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
