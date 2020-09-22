extends Node2D
var starting_npcs := 100
export (PackedScene) var NPC
export (PackedScene) var Player
var screen_size
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	screen_size = get_viewport_rect().size
	# TODO: logic for initializing npcs if not already created previously
	for npc in CharacterManager.npcs:
		spawn_npc(npc)
	spawn_player()
	#$Dialogue.init("res://Dialog/json/singing_v2.json", "Dave")


func spawn_npc(npc_data):
	var npc = NPC.instance()
	$YSort/npcs.add_child(npc)
	npc.init(npc_data)
	npc.position = get_random_pos()  # TODO: position based on data


func spawn_player():
	$YSort/Player.init(CharacterManager.player)
	$YSort/Player.position = Global.player_position
	#$YSort/Player.call_deferred("set_camera_current")


func get_random_pos() -> Vector2:
	var x = rng.randf_range(0, screen_size.x)
	var y = rng.randf_range(0, screen_size.y)
	var vector = Vector2(x, y)
	vector = $Navigation2D.get_closest_point(vector)
	return vector


func _on_Timer_timeout():
	var count = $YSort/npcs.get_child_count()
	var num = rng.randi_range(0, count-1)
	var chosen_npc = $YSort/npcs.get_child(num)
	chosen_npc.cough()
