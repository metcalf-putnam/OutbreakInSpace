extends Node

var littleMouse = 'awesome'
var exampleVar = true
var hasItem = false
var player_can_sing := false
var player_can_test := false
var first_lab_visit := true
var player_helmet := false
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
	print("var changed")
	var val = value
	
	if(val == "True") or (val == "true"):
		val = true
	elif(val == "False") or (val == "false"):
		val = false
	set(name, val)

func increment_cookies():
	pass
	
func singing_lesson():
	print("singing lesson being called!")
	player_can_sing = true
	
func visit_professor():
	first_lab_visit = false
	player_can_test = true

# `export` our functions and documentation about them! 
var functions = [
	'give_item()',
	'change_var("var", "value")',
	'singing_lesson()',
	'increment_cookies()'
]

var functionDocs = [
	'Give the player an item!',
	'Change the variable to a specified value',
	'give player singing lesson',
	'give player cookie'
]
