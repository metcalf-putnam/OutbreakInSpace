extends Node2D
var starting_npcs := 100
export (PackedScene) var NPC
var screen_size
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	# TODO: logic for initializing npcs if not already created previously
	for _i in range(starting_npcs):
		spawn_npc()
	$Dialogue.init("res://Dialog/json/basic_dave.json")

func spawn_npc():
	var npc = NPC.instance()
	$npcs.add_child(npc)
	npc.position = get_random_pos()


func get_random_pos() -> Vector2:
	var x = rng.randf_range(0, screen_size.x)
	var y = rng.randf_range(0, screen_size.y)
	var vector = Vector2(x, y)
	return vector
	
