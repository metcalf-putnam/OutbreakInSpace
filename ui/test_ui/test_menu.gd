extends NinePatchRect
export (PackedScene) var ChoiceButton

var characters
var lastBttnPos = 0
var timer = 0.0

const testing_text = "Who do you want to test?"
const dont_test_text = "No one for now"
const vacant_building_text = "No one inside. They must somewhere else now."
const continue_text = "Continue"

enum State{TEST_MENU, FINAL_MESSAGE}
var state = State.TEST_MENU
var details_offset = Vector2(15, -118)
var text_buffer = 17
var is_kinematic = false
var selected_character
var current_button_index = 0
var button_navigation_used = false

func _ready():
	hide()
	set_process(false)
	EventHub.connect("testing_character", self, "test_character")
	$DeclineButton.set_text(dont_test_text)


func _process(delta):
	timer += delta
	
	get_button_inputs()
	
	var mouse_over = false
	for i in range(0, get_node("Buttons").get_child_count()):
		if get_node('Buttons').get_child(i).mouse_over:
			show_details(i)
			mouse_over = true
		if get_node('Buttons').get_child(i).pressed and timer >= 0.5:
			if len(characters) <= i:
				cancel_test()
			else:
				if Global.energy <= 0:
					decline_test()
				else:
					if characters[i] is KinematicBody2D:
						characters[i].test()
						EventHub.emit_signal("character_tested", characters[i].data)
					else:
						characters[i]["last_tested"] = Global.day
						Global.add_test_results(characters[i], characters[i]["is_infected"])
						EventHub.emit_signal("character_tested", characters[i])
					confirm_test($Buttons.get_child(i).get_text())
			clear_buttons()
	if !mouse_over:
		selected_character = null
		$Details.hide()
	if is_kinematic:
		update_visuals()

# Testing menu popups contains 1 default button e.g "No one for now"
# In this case we need to create a method that will navigate through Buttons and DeclineButton 
# NOTE: If WASD controls will be remapped, we need to revisit this code.
func get_button_inputs():
	if $Buttons.get_child_count() > 0 and (
		Input.is_action_just_pressed("ui_up") or 
		Input.is_action_just_pressed("ui_down")):
		
		if Input.is_action_just_pressed("ui_up"):
			current_button_index += 1
		if Input.is_action_just_pressed("ui_down"):
			current_button_index -= 1
		
		current_button_index = clamp(current_button_index, 0, $Buttons.get_child_count())
		
		if current_button_index == 0:
			$DeclineButton.grab_focus()
		else:
			var button = $Buttons.get_child(current_button_index - 1)
			button.grab_focus()
	elif $Buttons.get_child_count() > 0 and Input.is_action_just_pressed("ui_accept"):
		if current_button_index != 0:
			var button = $Buttons.get_child(current_button_index - 1)
			button.click()


func update_visuals():
	# TODO: rewrite for clarity
	if selected_character:
		for character in characters: 
			character.show_glow(false)
			character.show_testing_label(false)
		selected_character.show_glow(true)
		selected_character.show_testing_label(true)
	else:
		for character in characters:
			character.show_glow(true)
			character.show_testing_label(false)
#
#	var has_selection = bool(selected_character)
#	for character in characters: 
#		character.show_glow(!has_selection)
#		character.show_testing_label(character == selected_character)
#	selected_character.show_glow(true)

func show_details(num : int):
	#move_details(num)
	var current_data
	if characters[num] is KinematicBody2D:
		current_data = characters[num].data
		selected_character = characters[num]
	else:
		current_data = characters[num]
	
	if current_data.has("name"):
		$Details/VBoxContainer/CharName/Details.text = current_data["name"]
	else:
		$Details/VBoxContainer/CharName/Details.text = "n/a"
		
	if current_data.has("home"):
		$Details/VBoxContainer/Home/Details.text = current_data["home"]
	else: 
		$Details/VBoxContainer/Home/Details.text = "n/a"
	
	if current_data.has("work"):
		$Details/VBoxContainer/Work/Details.text = current_data["work"]
	else:
		$Details/VBoxContainer/Work/Details.text = "n/a"
	
	if current_data.has("last_tested"):
		$Details/VBoxContainer/LastTested/Details.text = str(current_data["last_tested"])
	else:
		$Details/VBoxContainer/LastTested/Details.text = "never"
	
	$Details.show()
	

func move_details(num : int):
	var choice_position = $Buttons.get_child(num).rect_position
	choice_position = choice_position + details_offset
	choice_position.x = choice_position.x + $Buttons.get_child(num).rect_size.x
	$Details.rect_position = choice_position
	

func test_character(character_array, location_name = null):
	Global.active = false
	# TODO: make sure this is not needed here
	#emit_signal("player_controls_toggle", true)
	$PopUp.play()
	$Text.show()
	$Text.visible_characters = -1
	state = State.TEST_MENU
	
	if !location_name:
		$BuildingName.hide()
		is_kinematic = true
	else:
		is_kinematic = false
		var location_text = ""
		if location_name.begins_with("Class"):
			location_text = "School, " + location_name
		else:
			location_text = "Building " + location_name
		$BuildingName/Label.text = location_text
		format_building_name()
		$BuildingName.show()

	$Details.hide()
	show()
	characters = character_array
	set_process(true)
	
	if characters.size() == 0 and Global.player_can_test:
		$Text.bbcode_text = vacant_building_text
		$DeclineButton.set_text(continue_text)
		state = State.FINAL_MESSAGE
		return
	elif !Global.player_can_test:
		$Text.hide()
		return

	else:
		$Text.bbcode_text = testing_text
		get_tree().paused = true

	for character in characters:
		if character is KinematicBody2D:
			add_name_button(format_name_button(character.data))
		else:
			add_name_button(format_name_button(character))
	
	if get_node("Buttons").get_child_count() == 0:
		characters = []
	
	$DeclineButton.grab_focus()


func format_building_name():
	var label = $BuildingName/Label
	var x_size = label.get_font("font").get_string_size(label.text).x + text_buffer
	$BuildingName.rect_size.x = x_size
	$BuildingName/Label.rect_size.x = x_size
	

func add_name_button(option : String):
	var node = ChoiceButton.instance()
	node.set_text(option)
	node.rect_position = Vector2($ChoicePos.position.x, $ChoicePos.position.y + lastBttnPos)
	self.get_node("Buttons").add_child(node)
	node.show()
	lastBttnPos -= node.rect_size.y 


func clear_buttons():
	lastBttnPos = 0
	for child in get_node("Buttons").get_children():
		child.queue_free()


func cancel_test():
	$Text.bbcode_text = "no one was been tested"
	state = State.FINAL_MESSAGE
	clear_buttons()
	$DeclineButton.set_text(continue_text)
	$DeclineButton.grab_focus()
	

func decline_test():
	$Text.bbcode_text = "insufficient energy to test"
	state = State.FINAL_MESSAGE
	$DeclineButton.set_text(continue_text)
	$DeclineButton.grab_focus()


func confirm_test(name_tested : String):
	$Text.bbcode_text = name_tested + " has been tested. Results will be posted in " + str(Global.test_time) + " days."
	Global.decrement_energy()
	state = State.FINAL_MESSAGE
	$DeclineButton.set_text(continue_text)
	$DeclineButton.grab_focus()


func format_name_button(data):
	var label_text = data["name"].split(" ", true)[0]
	return label_text


func _on_DeclineButton_is_pressed():
	match state:
		State.FINAL_MESSAGE:
			exit_menu()
		State.TEST_MENU:
			cancel_test()


func reset_characters():
	if !characters:
		print("no characters to reset")
		return
	get_tree().call_group("character", "show_testing_label", false)
	characters = []


func exit_menu():
	$DeclineButton.set_text(dont_test_text)
	get_tree().set_input_as_handled()
	reset_characters()
	clear_buttons()
	set_process(false)
	EventHub.emit_signal("dialogue_finished")
	hide()
	Global.active = true
	# TODO: make sure this is not needed here
	#emit_signal("player_controls_toggle", false)
	get_tree().paused = false
	
	if Global.energy == 0 and not Global.no_more_energy:
		EventHub.emit_signal("no_energy_left")
