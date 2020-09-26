extends CanvasLayer

var character_details_scn = preload("res://ui/CharacterDetails.tscn")

onready var scroll_container = $NinePatchRect/ScrollContainer
onready var list_container = $NinePatchRect/ScrollContainer/HBoxContainer
onready var nothing = $NinePatchRect/Nothing

func _ready():
	nothing.hide()
	scroll_container.hide()
	show_positive_characters()


func show_positive_characters():
	
	if Global.positive_ids.size() == 0:
		nothing.show()
		return
	
	for id in Global.positive_ids:
		
		# Get character details
		var details
		var path
		if int(id) == CharacterManager.player_id:
			var player = get_tree().root.get_node("Root/YSort/Player")
			details = player.data
			path = player.get_path()
		else:
			for npc in get_tree().root.get_node("Root/YSort/npcs").get_children():
				if int(id) == npc.data["id"]:
					details = npc.data
					path = npc.get_path()
		
		# Create profile
		var character_details = character_details_scn.instance()
		character_details.connect("play_mini_game", self, "_on_play_mini_game")
		list_container.add_child(character_details)
		character_details.init(details, path)
	
	scroll_container.show()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_SPACE:
			queue_free()


func _on_play_mini_game(settings):
	EventHub.emit_signal("start_mini_game")
	queue_free()