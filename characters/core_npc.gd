extends Character
export(String, FILE, "*.json") var dialog_file
export var full_name : String
export var infective_dose : int
export (String, FILE, "*.png") var sprite_file
export (String, FILE, "*.png") var helmet_file


func _ready():
	data = CharacterManager.get_core_npc(full_name)
	if infective_dose:
		data["infective_dose"] = infective_dose
	init(data)

func _on_Interactable_dialogue_started():
	EventHub.emit_signal("new_dialogue", dialog_file, full_name)

func update_sprite():
	if data["has_helmet"] == true: 
		$Helmet.show()
	else:
		$Helmet.hide()

	$Sprite.texture = load(sprite_file)
	$Helmet.texture = load(helmet_file)
