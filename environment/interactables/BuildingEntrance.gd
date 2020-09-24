extends Interactable
var characters_inside = []


func _ready():
	._ready()
	$Exclamation.hide()
	EventHub.connect("building_entered", self, "enter")
	EventHub.connect("building_exited", self, "exit")


func interact():
	$Control.hide()
	print("NPCs in ", name)
	for character in characters_inside:
		print(character["name"])
	Global.decrement_energy()
	# TODO: open testing menu with people inside


func enter(npc_dic):
	if npc_dic.has("work") and npc_dic["work"] == name:
		if !characters_inside.has(npc_dic):
			characters_inside.append(npc_dic)


func exit(npc_dic, building_name):
	if npc_dic.has("work") and npc_dic["work"] == name:
		if !characters_inside.has(npc_dic):
			characters_inside.erase(npc_dic)
