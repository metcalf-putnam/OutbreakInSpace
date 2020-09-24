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
	spawn_player()
	for npc in CharacterManager.npcs:
		spawn_npc(npc)
		yield(get_tree().create_timer(.75), "timeout")
	#$Dialogue.init("res://Dialog/json/singing_v2.json", "Dave")

func spawn_npc(npc_data):
	var npc = NPC.instance()
	$YSort/npcs.add_child(npc)
	npc.init(npc_data)
	npc.set_nav_node($Navigation2D)
	#npc.global_position = $Navigation2D.get_closest_point(get_home(npc_data))
	npc.position = get_home(npc_data)
	#npc.set_target_location(get_random_pos())
	npc.set_target_location(get_work(npc_data))


func spawn_player():
	$YSort/Player.init(CharacterManager.player)


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
	
	
func get_home(data) -> Vector2:
	var home_loc = Vector2()
	if data.has("home") and $Navigation2D/Homes.has_node(data["home"]):
		home_loc = $Navigation2D/Homes.get_node(data["home"]).global_position
	return home_loc
	
func get_work(data) -> Vector2:
	var work_loc = Vector2()
	if data.has("work") and $Navigation2D/Locations.has_node(data["work"]):
		work_loc = $Navigation2D/Locations.get_node(data["work"]).global_position
	return work_loc
