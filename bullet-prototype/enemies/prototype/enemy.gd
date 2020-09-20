extends Node2D

var nodes = ["4-S-+","4-S-X"];
var current_node = 0

export(int) var is_alternating = 0

func _ready():
	if is_alternating:
		for n in nodes:
			get_node(n).disable_self()
		get_node(nodes[current_node]).enable_self()

func _on_Alternate_timeout():
	
	get_node(nodes[current_node]).disable_self()
	current_node += 1
	if current_node == nodes.size():
		current_node = 0
	get_node(nodes[current_node]).enable_self()
	
	get_node("Alternate").start()
	pass # Replace with function body.
	
func disable_self():
	if self is Node2D:
		for n in get_children():
			n.get_node("Spawner").set_process(false)
	else:
		get_node("Spawner").set_process(false)

func enable_self():
	if self is Node2D:
		for n in get_children():
			n.get_node("Spawner").set_process(true)
	else:
		get_node("Spawner").set_process(true)
