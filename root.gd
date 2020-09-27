extends Node2D
var starting_npcs := 100
export (PackedScene) var NPC
export (PackedScene) var Player
var screen_size
var rng = RandomNumberGenerator.new()
var lower_energy_limit := 0

func _ready():
	rng.randomize()
	screen_size = get_viewport_rect().size
	EventHub.connect("building_exited", self, "on_building_exited")
	
	if Global.player_settings.help_character_id != 0:
		update_character_health(Global.player_settings.help_character_id)

	spawn_player()
	if Global.energy <= lower_energy_limit:
		return
	
	var building_occupy_type
	
	# Middle of day, everyone at work (if applicable)
	if Global.energy > lower_energy_limit and Global.energy < Global.max_energy:
		building_occupy_type = "work"
	# Start of day, everyone at home
	elif Global.energy == Global.max_energy:
		building_occupy_type = "home"
		
	for npc in CharacterManager.npcs:
		match building_occupy_type:
			"home":
				if $Navigation2D/Homes.find_node(npc[building_occupy_type]) is Area2D:
					EventHub.emit_signal("building_occupied", npc, building_occupy_type)
			"work":
				if $Navigation2D/Locations.find_node(npc[building_occupy_type]) is Area2D:
					EventHub.emit_signal("building_occupied", npc, building_occupy_type)
				else:
					spawn_npc(npc, "wander")

	EventHub.emit_signal("leave_building", building_occupy_type)


func validate_character_status(data):
	if data["viral_load"] <= 0:
		data["viral_load"] = 0
		data["is_infected"] = false
		data["is_contagious"] = false
		Global.total_infections -= 1


func update_character_health(id):
	if id == CharacterManager.player_id:
		CharacterManager.player["viral_load"] -= Global.player_settings.extraction_points
		if CharacterManager.player["viral_load"] <= 0:
			CharacterManager.player["viral_load"] = 0
		CharacterManager.player["is_infected"] = false
		CharacterManager.player["is_contagious"] = false
	else:
		for npc in CharacterManager.npcs:
			if id == npc["id"]:
				npc["viral_load"] -= Global.player_settings.extraction_points
				validate_character_status(npc)
	
	Global.player_settings.extraction_points = 0
	Global.player_settings.character_id = 0


func send_npcs_home():
	for npc in $YSort/npcs.get_children():
		if !npc.is_in_group("core_npc"):
			var home_loc = get_home(npc.data)
			npc.set_target_location(home_loc)
	EventHub.emit_signal("work_ended")


func spawn_npc(npc_data, location : String):
	var npc = NPC.instance()
	$YSort/npcs.add_child(npc)
	npc.init(npc_data)
	npc.set_nav_node($Navigation2D)
	match location:
		"home":
			npc.position = get_home(npc_data)
			npc.set_target_location(get_work(npc_data))
		"work":
			npc.position = get_work(npc_data)
			npc.set_target_location(get_home(npc_data))
		"wander":
			npc.position = get_work(npc_data)
			npc.wander()


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
	else:
		return get_random_pos()
	return home_loc


func get_work(data) -> Vector2:
	var work_loc = Vector2()
	if data.has("work") and $Navigation2D/Locations.has_node(data["work"]):
		work_loc = $Navigation2D/Locations.get_node(data["work"]).global_position
	else:
		return get_random_pos()
	return work_loc


func on_building_exited(npc_data, type):
	spawn_npc(npc_data, type)


func _on_DayTimer_timeout():
	send_npcs_home()
