extends Character
export(String, FILE, "*.json") var dialog_file
export var full_name : String
export var infective_dose : int
export var is_immune : bool
export (String, FILE, "*.png") var sprite_file
export (String, FILE, "*.png") var helmet_file
export var home : String
export var work : String
export var npc_handle : String
export (String, FILE, "*.png") var portrait_file

var Events = ["virus_detected", "first_results", "first_positive", "first_death"]
var event

func _ready():
	data = CharacterManager.get_core_npc(npc_handle, portrait_file, is_immune)
	if infective_dose:
		data["infective_dose"] = infective_dose
#	data["is_infected"] = is_infected
#	data["is_contagious"] = is_contagious
	init(data)
	if data["health"] <= 0:
		queue_free()
	data["name"] = full_name
	if home:
		data["home"] = home
	if work:
		data["work"] = work
	if npc_handle:
		data["npc_handle"] = npc_handle
	if !data.has("event_checks"):
		data["event_checks"] = {}
		for e in Events:
			data["event_checks"][e] = false
	check_special_dialog()
	update_testing_label()
	if Global.first_lab_visit and npc_handle == "granny":
		$Interactable.set_new_info(true)
	
	if npc_handle == "singer":
		Global.connect("singing_lesson", self, "_on_singing_lesson")


func get_dialog_file():
	var file2check = File.new()
	var file_path = ""
	if !Global.first_lab_visit and !data["event_checks"]["virus_detected"]:
		event = "virus_detected"
		file_path = get_file_path(event)
		if file2check.file_exists(file_path):
			return file_path
	if Global.first_results and !data["event_checks"]["first_results"]:
		event = "first_results"
		file_path = get_file_path(event)
		if file2check.file_exists(file_path):
			return file_path
	if Global.first_positive and !data["event_checks"]["first_positive"]:
		event = "first_positive"
		file_path = get_file_path(event)
		if file2check.file_exists(file_path):
			return file_path
	if Global.first_death and !data["event_checks"]["first_death"]:
		event = "first_death"
		file_path = get_file_path(event)
		if file2check.file_exists(file_path):
			return file_path
	else:
		event = null
		return null


func get_file_path(event_name):
	return "res://Dialog/" + "json/"  + npc_handle + "_" + event_name + ".json"


func _on_Interactable_dialogue_started():
	var event_dialogue = get_dialog_file()
	if event_dialogue:
		EventHub.emit_signal("new_dialogue", event_dialogue, full_name)
		data["event_checks"][event] = true
		event = null
	else:
		EventHub.emit_signal("new_dialogue", dialog_file, full_name)
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("npc_dialogue", self, "_on_dialog")


func _on_dialogue_finished():
	EventHub.disconnect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.disconnect("npc_dialogue", self, "_on_dialog")
	if Global.convinced and !data["has_helmet"]:
		data["has_helmet"] = true
		Global.convinced = false
		Global.npcs_convinced += 1
		update_sprite()
		get_tree().call_deferred("player", "update_sprite")
		
	
	
func _on_dialog():
	speak()


func update_sprite():
	if data["has_helmet"] == true: 
		$Helmet.show()
	else:
		$Helmet.hide()

	$Sprite.texture = load(sprite_file)
	$Helmet.texture = load(helmet_file)


func check_special_dialog():
	if Global.first_lab_visit and npc_handle == "professor":
		$Interactable.set_new_info(true)
		return
	if !Global.player_can_sing and npc_handle == "singer":
		$Interactable.set_new_info(true)
		return
	if get_dialog_file():
		$Interactable.set_new_info(true)
	else:
		$Interactable.set_new_info(false)


func _on_singing_lesson():
	print("giving singing lesson")
	sing()
