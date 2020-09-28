extends Character
export(String, FILE, "*.json") var dialog_file
export var full_name : String
export var infective_dose : int
export (String, FILE, "*.png") var sprite_file
export (String, FILE, "*.png") var helmet_file
export var home : String
export var work : String
export var npc_handle : String
export (String, FILE, "*.png") var portrait_file


func _ready():
	data = CharacterManager.get_core_npc(npc_handle, portrait_file)
	if infective_dose:
		data["infective_dose"] = infective_dose
#	data["is_infected"] = is_infected
#	data["is_contagious"] = is_contagious
	init(data)
	data["name"] = full_name
	if home:
		data["home"] = home
	if work:
		data["work"] = work
	if npc_handle:
		data["npc_handle"] = npc_handle
	update_testing_label()


func _on_Interactable_dialogue_started():
	EventHub.emit_signal("new_dialogue", dialog_file, full_name)
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.connect("npc_dialogue", self, "_on_dialog")


func _on_dialogue_finished():
	EventHub.disconnect("dialogue_finished", self, "_on_dialogue_finished")
	EventHub.disconnect("npc_dialogue", self, "_on_dialog")
	
	
func _on_dialog():
	speak()


func update_sprite():
	if data["has_helmet"] == true: 
		$Helmet.show()
	else:
		$Helmet.hide()

	$Sprite.texture = load(sprite_file)
	$Helmet.texture = load(helmet_file)
