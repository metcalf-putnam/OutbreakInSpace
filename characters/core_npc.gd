extends Character
export(String, FILE, "*.json") var dialog_file
export var full_name : String
export var infective_dose : int
export (String, FILE, "*.png") var sprite_file
export (String, FILE, "*.png") var helmet_file
export var is_infected = true
export var is_contagious = true


func _ready():
	data = CharacterManager.get_core_npc(full_name)
	if infective_dose:
		data["infective_dose"] = infective_dose
	data["is_infected"] = is_infected
	data["is_contagious"] = is_contagious
	init(data)
	data["name"] = full_name


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
