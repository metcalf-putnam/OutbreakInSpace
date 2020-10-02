extends Interactable
var characters_inside = []
export var type := "work"
var rng = RandomNumberGenerator.new()


func _ready():
	._ready()
	rng.randomize()
	has_new_info = false
	$Exclamation.hide()
	EventHub.connect("building_entered", self, "enter")
	EventHub.connect("building_occupied", self, "occupy")
	EventHub.connect("energy_used", self, "_on_energy_used")
	EventHub.connect("leave_building", self, "_on_leave_building")


func interact():
	$Control.hide()
	print("NPCs in ", name)
	for character in characters_inside:
		print(character["name"])
	EventHub.emit_signal("testing_character", characters_inside, name)


func occupy(npc_dic, type_in):
	if type != type_in:
		return
	if npc_dic.has(type) and npc_dic[type] == name:
		if !characters_inside.has(npc_dic):
			characters_inside.append(npc_dic)


func enter(npc, building_type):
	if building_type != type:
		return
	var npc_dic = npc.data
	if npc_dic.has(type) and npc_dic[type] == name:
		if !characters_inside.has(npc_dic):
			characters_inside.append(npc_dic)
		npc.queue_free()


func exit():
	if len(characters_inside) > 0:
		if !get_tree().paused:
			spawn_npc()
	$Timer.start(rng.randf_range(1, 15))


func spawn_npc():
	# Stay home if tested positive (all should occupants stay home instead)?
	if characters_inside[0] in Global.positive_characters and characters_inside[0]["is_infected"]:
		return
	if characters_inside[0]["race"] == "Blues" and Global.essential_workers:
		return
	if characters_inside[0]["type"] == "Child" and Global.essential_workers:
		return 
	var npc = characters_inside.pop_front()
	EventHub.emit_signal("building_exited", npc, type)
	characters_inside.erase(npc)


func _on_leave_building(building_type):
	if type != building_type:
		return
	exit()
	

func _on_energy_used():
	pass


func _on_Timer_timeout():
	exit()
