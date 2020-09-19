extends Node2D
var starting_npcs := 100
export (PackedScene) var NPC
export (PackedScene) var Player
var screen_size
var rng = RandomNumberGenerator.new()


func _ready():
	screen_size = get_viewport_rect().size
	# TODO: logic for initializing npcs if not already created previously
	for npc in CharacterManager.npcs:
		spawn_npc(npc)
	spawn_player()
	$Dialogue.init("res://Dialog/json/singing_lesson.json", "Juan")
	

func spawn_npc(npc_data):
	var npc = NPC.instance()
	$YSort/npcs.add_child(npc)
	npc.init(npc_data)
	npc.position = get_random_pos()  # TODO: position based on data


func spawn_player():
	var player = Player.instance()
	$YSort.add_child(player)
	player.init(CharacterManager.player)
	player.position = Global.player_position


func get_random_pos() -> Vector2:
	var x = rng.randf_range(0, screen_size.x)
	var y = rng.randf_range(0, screen_size.y)
	var vector = Vector2(x, y)
	return vector
