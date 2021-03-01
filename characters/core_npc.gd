extends Character
class_name CoreNPC

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

var Events = ["virus_detected", "first_results", "first_positive", "first_death", "testing_completed"]
var event

func get_event_dialog_file_path():
	var file2check = File.new()
	var file_path = ""
	event = null
	
	if !Global.first_lab_visit and !data["event_checks"]["virus_detected"]:
		event = "virus_detected"
	if Global.testing_completed and !data["event_checks"]["testing_completed"]:
		event = "testing_completed"
	if Global.first_results and !data["event_checks"]["first_results"]:
		event = "first_results"
	if Global.first_positive and !data["event_checks"]["first_positive"]:
		event = "first_positive"
	if Global.first_death and !data["event_checks"]["first_death"]:
		event = "first_death"
	if event == null:
		return null
	
	file_path = "res://dialog/json/" + npc_handle + "_" + event + ".json"
	print("checking file path: ", file_path)
	if file2check.file_exists(file_path):
		return file_path

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
	if Global.helmet_mandate:
		data["has_helmet"] = true
	check_special_dialog()
	update_testing_label()
	if Global.first_lab_visit and npc_handle == "granny":
		$Interactable.set_new_info(true)
	
	if npc_handle == "singer":
		Global.connect("singing_lesson", self, "_on_singing_lesson")


func _on_Interactable_dialogue_started():
	var event_dialogue = get_event_dialog_file_path()
	if event_dialogue:
		EventHub.emit_signal("new_dialogue", event_dialogue, full_name, portrait_file)
		data["event_checks"][event] = true
		event = null
	else:
		EventHub.emit_signal("new_dialogue", dialog_file, full_name, portrait_file)
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("npc_dialogue", self, "_on_dialog")
	Logger.create_log_for(full_name, Logger.LOG_TYPE.NPC_INTERACTION)


func _on_dialogue_finished():
	EventHub.disconnect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.disconnect("npc_dialogue", self, "_on_dialog")
	Global.conversations_had += 1
	if Global.convinced and !data["has_helmet"]:
		data["has_helmet"] = true
		if npc_handle == "work_friend":
			CharacterManager.player["has_helmet"] = true
			Global.player_helmet = true
		Global.convinced = false
		Global.npcs_convinced += 1
		update_sprite()
		get_tree().call_group("player", "update_sprite")
		
	
	
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
	print("checking special dialogue")
	if Global.first_lab_visit and npc_handle == "professor":
		$Interactable.set_new_info(true)
		return
	if !Global.player_can_sing and npc_handle == "singer":
		$Interactable.set_new_info(true)
		return
	if get_event_dialog_file_path():
		print("there is special dialogue for ", full_name)
		$Interactable.set_new_info(true)
	else:
		$Interactable.set_new_info(false)


func _on_singing_lesson():
	print("giving singing lesson")
	sing()
	
	
func react_to_singing():
	match npc_handle:
		"singer":
			sing()
		"professor":
			$Emote.emote("mad")
		_:
			$Emote.emote("happy")
