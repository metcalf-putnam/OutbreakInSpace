extends Node

var littleMouse = 'awesome'
var exampleVar = true
var hasItem = false
var player_can_sing := false
var player_position := Vector2(300, 300)


# `export` our variables and quick documentation about them on hover
var variables = [
	'littleMouse',
	'exampleVar',
	'hasItem',
]
var varTooltips = [
	'What is littleMouse',
	'An example var!',
	'Does the user have the item?'
]

#====> FUNCTIONS
func give_item():
	hasItem = true

func change_var(name, value):
	var val = value
	
	if(val == "True") or (val == "true"):
		val = true
	elif(val == "False") or (val == "false"):
		val = false
	set(name, val)

func increment_cookies():
	pass
	
func singing_lesson():
	player_can_sing = true

# `export` our functions and documentation about them! 
var functions = [
	'give_item()',
	'change_var("var", "value")'
]

var functionDocs = [
	'Give the player an item!',
	'Change the variable to a specified value'
]
