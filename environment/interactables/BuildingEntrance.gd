extends Interactable
var characters_inside = []


func _ready():
	._ready()
	has_new_info = false
	$Exclamation.hide()
	EventHub.connect("building_entered", self, "enter")
	EventHub.connect("work_ended", self, "exit")
	EventHub.connect("building_occupied", self, "occupy")


func interact():
	$Control.hide()
	print("NPCs in ", name)
	for character in characters_inside:
		print(character["name"])
	if Global.player_can_test:
		if Global.energy >= 1:
			EventHub.emit_signal("testing_character", characters_inside, name)
		else:
			EventHub.emit_signal("insufficient_energy")


func occupy(npc_dic):
	if npc_dic.has("work") and npc_dic["work"] == name:
		if !characters_inside.has(npc_dic):
			characters_inside.append(npc_dic)


func enter(npc):
	var npc_dic = npc.data
	if npc_dic.has("work") and npc_dic["work"] == name:
		if !characters_inside.has(npc_dic):
			characters_inside.append(npc_dic)
		npc.queue_free()


func exit():
	while len(characters_inside) > 0:
		var npc = characters_inside.pop_front()
		EventHub.emit_signal("building_exited", npc)
		characters_inside.erase(npc)
		yield(get_tree().create_timer(1), "timeout")
