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


func _ready():
	hide()
	set_process(false)
	EventHub.connect("testing_character", self, "test_character")
	$DeclineButton.set_text(dont_test_text)


func _process(delta):
	timer += delta
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
		$Details.hide()


func show_details(num : int):
	move_details(num)
	
	var current_data
	if characters[num] is KinematicBody2D:
		current_data = characters[num].data
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
	
	$Details.show()
	

func move_details(num : int):
	var choice_position = $Buttons.get_child(num).rect_position
	choice_position = choice_position + details_offset
	choice_position.x = choice_position.x + $Buttons.get_child(num).rect_size.x
	$Details.rect_position = choice_position
	

func test_character(character_array):
	Global.active = false
	#emit_signal("player_controls_toggle", true)
	$PopUp.play()
	$Text.show()
	$Text.visible_characters = -1
	state = State.TEST_MENU

	#$Name_NinePatchRect.hide()
	$Details.hide()
	show()
	characters = character_array
	set_process(true)
	
	if characters.size() == 0 and Global.player_can_test:
		$Text.bbcode_text = vacant_building_text
		#$Space_NinePatchRect.show()
		return
	elif !Global.player_can_test:
		$Text.hide()
		#$Space_NinePatchRect.show()
		return

	else:
		$Text.bbcode_text = testing_text
		#$Space_NinePatchRect.hide()
		get_tree().paused = true

	for character in characters:
		if character is KinematicBody2D:
			character.show_testing_label(true)
			add_name_button(format_name_button(character.data))
		else:
			add_name_button(format_name_button(character))
	
	if get_node("Buttons").get_child_count() == 0:
		characters = []
		
	$DeclineButton.grab_focus()
	#add_name_button(dont_test_text)


func test_building(character_array, location_name):
	var location_text = ""
	if location_name.begins_with("Class"):
		location_text = "School, " + location_name
	else:
		location_text = "Building " + location_name
		$Name_NinePatchRect/Name.text = location_text
		$Name_NinePatchRect.rect_size.x = $Name_NinePatchRect/Name.get_font("font").get_string_size(location_text).x + 23
		$Name_NinePatchRect.show()


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
	

func decline_test():
	$Text.bbcode_text = "insufficient energy to test"
	state = State.FINAL_MESSAGE
	$DeclineButton.set_text(continue_text)


func confirm_test(name_tested : String):
	$Text.bbcode_text = name_tested + " has been tested. Results will be posted in " + str(Global.test_time) + " days."
	Global.decrement_energy()
	state = State.FINAL_MESSAGE
	$DeclineButton.set_text(continue_text)


func format_name_button(data):
	var label_text = data["name"].split(" ", true)[0]
#	if data.has("home"):
#		label_text = label_text + ", h: " + data["home"]
#	if data.has("work"):
#		label_text = label_text + ", w: " + data["work"]
#	if data.has("last_tested"):
#		label_text = label_text + ", lt: Day " + str(data["last_tested"])
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
	emit_signal("player_controls_toggle", false)
	get_tree().paused = false
