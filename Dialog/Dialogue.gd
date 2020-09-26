extends NinePatchRect

var lastBttnPos = 0
var timer = 0

var parser
var dialogue_data
var block
var data = {}
const action_prefix = "<"
var is_final := false
export (PackedScene) var ChoiceButton
enum State {DIALOGUE, TESTING, MESSAGE}
var state = State.DIALOGUE
const testing_text := "Who do you want to test? (Cost: 1 energy)"
var characters = []
var is_mini_game = false

func _ready():
	set_process(false)
	hide()
	EventHub.connect("new_dialogue", self, "init")
	EventHub.connect("testing_character", self, "test_character")
	EventHub.connect("insufficient_energy", self, "error")


func _process(delta):
	# TODO: get this out of process for speed improvements?
	# TODO: add modes
	timer += delta
	match state:
		State.DIALOGUE:
			for i in range(0, get_node("Buttons").get_child_count()):
				if get_node('Buttons').get_child(i).pressed and timer >= 0.5:
					var option_text = $Buttons.get_child(i).get_text()
					
					if option_text == "Show Positives":
						end_dialogue()
						Global.show_positives()
						
					if !option_text.begins_with(action_prefix):
						EventHub.emit_signal("player_spoke")
					step_forward(i)
		State.TESTING:
			for i in range(0, get_node("Buttons").get_child_count()):
				if get_node('Buttons').get_child(i).pressed and timer >= 0.5:
					if len(characters) <= i:
						cancel_test()
					else:
						if characters[i] is KinematicBody2D:
							characters[i].test()
						else:
							characters[i]["last_tested"] = Global.day
							Global.add_test_results(characters[i]["id"], characters[i]["name"], characters[i]["is_infected"])
						confirm_test($Buttons.get_child(i).get_text())
					clear_buttons()
					$Space_NinePatchRect.show()

func step_forward(i):
	if i == -1:
		block = parser.next()
	else:
		block = parser.next(block.options[i].key)
	next()
	timer = 0


func init(file_path : String, name := " "):
	
	EventHub.emit_signal("npc_dialogue")
	state = State.DIALOGUE
	$Name_NinePatchRect/Name.text = name
	$Name_NinePatchRect.show()
	set_process(true)
	parser = WhiskersParser.new(Global)
	parser.set_format_dictionary({"player_name" : "Knuthl"})
	dialogue_data = parser.open_whiskers(file_path)
	block = parser.start_dialogue(dialogue_data)
	next()


func test_character(character_array, location_name = null):
	if !location_name:
		$Name_NinePatchRect.hide()
	else:
		$Name_NinePatchRect/Name.text = location_name
		$Name_NinePatchRect.show()
	show()
	characters = character_array
	state = State.TESTING
	set_process(true)
	
	if characters.size() == 0:
		$Text.bbcode_text = "No one inside"
		is_final = true
		$Space_NinePatchRect.show()
		return
	else:
		$Text.bbcode_text = testing_text
		$Space_NinePatchRect.hide()
		get_tree().paused = true
	
	var to_remove = []
	for character in characters:
		if character is KinematicBody2D:
			if not character.data["done_test"]:
				character.show_testing_label(true)
				add_name_button(character.get_full_name())
			else:
				to_remove.append(characters.find(character, 0))
		elif not character["done_test"]:
			add_name_button(character["name"])
	
	for character in to_remove:
		characters.remove(character)
	
	if get_node("Buttons").get_child_count() == 0:
		characters = []
		
	add_name_button("No one for now")

	# Labels above or below characters with name and last tested day


func error():
	$Name_NinePatchRect.hide()
	$Space_NinePatchRect.show()
	show()
	state = State.MESSAGE
	$Text.bbcode_text = "Insufficient Energy"
	set_process(true)
	is_final = true


func confirm_test(name_tested : String):
	$Text.bbcode_text = name_tested + " has been tested. Results will be posted in " + str(Global.test_time) + " days."
	Global.decrement_energy()
	is_final = true
	get_tree().paused = false


func cancel_test():
	$Text.bbcode_text = "no one was been tested"
	is_final = true
	get_tree().paused = false


func next():
	clear_buttons()
	if block:
		show()
		get_node("Text").parse_bbcode(block.text)
		var count = 0
		for option in block.options:
			add_button(option)
			count += 1
		if count > 0:
			$Space_NinePatchRect.hide()
		else:
			$Space_NinePatchRect.show()
		if block.is_final:
			is_final = true
	EventHub.emit_signal("npc_dialogue")

func add_name_button(name : String):
	var node = ChoiceButton.instance()
	node.set_text(name)
	node.rect_position = Vector2($ChoicePos.position.x, $ChoicePos.position.y + lastBttnPos)
	self.get_node("Buttons").add_child(node)
	node.show()
	lastBttnPos -= node.rect_size.y + 3


func add_button(button_data):
	var node = ChoiceButton.instance()
	node.set_text(button_data.text)
	node.rect_position = Vector2($ChoicePos.position.x, $ChoicePos.position.y + lastBttnPos)
	self.get_node("Buttons").add_child(node)
	node.show()
	node.set_name(button_data.key)
	print("data.key:", button_data.key)
	lastBttnPos -= node.rect_size.y + 3


func reset():
	data = {}
	lastBttnPos = 0
	clear_buttons()
	$Name_NinePatchRect.hide()


func clear_buttons():
	lastBttnPos = 0
	for child in get_node("Buttons").get_children():
		child.queue_free()


func reset_characters():
	if !characters:
		print("no characters to reset")
		return
	get_tree().call_group("character", "show_testing_label", false)
	characters = []


func _unhandled_input(event):
	if !is_processing():
		return
	if !event.is_action_pressed("ui_accept"):
		return
	if is_final:
		end_dialogue()
	elif $Buttons.get_child_count() == 0 and state == State.DIALOGUE:
		step_forward(-1)


func end_dialogue():
	get_tree().set_input_as_handled()
	reset_characters()
	clear_buttons()
	is_final = false
	set_process(false)
	EventHub.emit_signal("dialogue_finished")
	hide()