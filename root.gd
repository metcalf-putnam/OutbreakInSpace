extends Node2D
var starting_npcs := 100
export (PackedScene) var NPC
export (PackedScene) var Player
var screen_size
var rng = RandomNumberGenerator.new()
var lower_energy_limit := 0

func _ready():
	Music.change_state("normal")
	rng.randomize()
	screen_size = get_viewport_rect().size
	EventHub.connect("building_exited", self, "on_building_exited")
	EventHub.connect("dialogue_finished", self, "_on_dialog_finished")
	EventHub.connect("computer_interaction", self, "_on_computer_interaction")
	
	spawn_player()
	
	var building_occupy_type
	
	# Middle of day, everyone at work (if applicable)
	if Global.energy > lower_energy_limit and Global.energy < Global.max_energy:
		building_occupy_type = "work"
	else:
		building_occupy_type = "home"
		
	for npc in CharacterManager.npcs:
		if npc["health"] <= 0:
			continue
		match building_occupy_type:
			"home":
				if $Navigation2D/Homes.find_node(npc[building_occupy_type]) is Area2D:
					EventHub.emit_signal("building_occupied", npc, building_occupy_type)
			"work":
				if $Navigation2D/Locations.find_node(npc[building_occupy_type]) is Area2D:
					EventHub.emit_signal("building_occupied", npc, building_occupy_type)
				else:
					spawn_npc(npc, "wander")
					yield(get_tree().create_timer(0.75), "timeout")
	if Global.energy > 0:
		EventHub.emit_signal("leave_building", building_occupy_type)


func validate_character_status(data):
	if data["viral_load"] <= 0:
		data["viral_load"] = 0
		data["is_infected"] = false
		data["is_contagious"] = false
		Global.total_infections -= 1


func send_npcs_home():
	EventHub.emit_signal("work_ended")
	$GoHomeTimer.start()


func spawn_npc(npc_data, location : String):
	if npc_data["health"] <= 0:
		return
	if Global.helmet_mandate:
		npc_data["has_helmet"] = true
	var npc = NPC.instance()
	$YSort/npcs.add_child(npc)
	npc.init(npc_data)
	npc.set_nav_node($Navigation2D)
	match location:
		"home":
			npc.position = get_home(npc_data)
			npc.set_target_location(get_work(npc_data), "work")
		"work":
			npc.position = get_work(npc_data)
			npc.set_target_location(get_home(npc_data), "home")
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
	if chosen_npc.data.has("npc_handle"):
		if chosen_npc.data["npc_handle"] == "mini_prof":
			return
		if chosen_npc.data["npc_handle"] == "professor":
			return
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


func _on_GoHomeTimer_timeout():
	var count = $YSort/npcs.get_child_count()
	var num = rng.randi_range(0, count-1)
	var chosen_npc = $YSort/npcs.get_child(num)
	if chosen_npc.has_method("set_target_location"):
		chosen_npc.set_target_location(get_home(chosen_npc.data), "home")


func _on_dialog_finished():
	get_tree().call_group("core_npc", "check_special_dialog")


func _on_computer_interaction():
	var morning_report = preload("res://ui/DayStart.tscn").instance()
	get_tree().get_root().add_child(morning_report)
