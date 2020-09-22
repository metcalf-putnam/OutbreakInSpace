extends Position2D

var grid_size = Vector2()
var grid_position = Vector2()
onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	grid_size = OS.get_real_window_size()/2
	print("grid size: ", grid_size)
	set_as_toplevel(true)
	update_grid_position()

func update_grid_position():
	var x = round(parent.global_position.x / grid_size.x)
	var y = round(parent.global_position.y / grid_size.y)
	var new_grid_position = Vector2(x, y)
	if grid_position == new_grid_position:
		return
	grid_position = new_grid_position
	position = grid_position * grid_size

func _physics_process(delta):
	update_grid_position()
