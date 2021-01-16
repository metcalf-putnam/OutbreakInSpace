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
enum State {DIALOGUE, TESTING, MESSAGE, HOUSE}
var state = State.DIALOGUE
const testing_text := "Who do you want to test (must be nearby)? Home addresses, workplaces, and day of last test shown when applicable (Cost: 1 energy)"
var characters = []

# Voice
enum TEXT_STATE { NA, READY, INPROGRESS, COMPLETE }
var text_state = TEXT_STATE.NA
var ticks_before_next_letter = 5
var current_tick = 0
var text_length = 0

# Button navigation
var current_button_index = 0

signal player_controls_toggle

func _ready():
	set_process(false)
	hide()
	EventHub.connect("new_dialogue", self, "init")
	#EventHub.connect("testing_character", self, "test_character")
	EventHub.connect("insufficient_energy", self, "error")
	EventHub.connect("going_in_house_dialogue", self, "_on_going_in_house_dialogue")
	EventHub.connect("going_out_house_dialogue", self, "_on_going_out_house_dialogue")
	EventHub.connect("tv_dialogue", self, "_on_tv_dialogue")
	EventHub.connect("bed_dialogue", self, "_on_bed_dialogue")
	EventHub.connect("computer_dialogue", self, "_on_computer_dialogue")
	EventHub.connect("pet_dialogue", self, "_on_pet_dialogue")
	parser = WhiskersParser.new(Global)


func _process(delta):
	# TODO: get this out of process for speed improvements?
	# TODO: add modes
	timer += delta
	
	if text_state == TEXT_STATE.INPROGRESS:
		current_tick += 1
		if current_tick == ticks_before_next_letter:
			current_tick = 0
			get_node("Text").visible_characters += 1
			speech()
			if get_node("Text").visible_characters == get_node("Text").text.length():
				text_state = TEXT_STATE.COMPLETE
				show_buttons()
	else:
		
		match state:
			State.DIALOGUE:
				for i in range(0, get_node("Buttons").get_child_count()):
					if get_node('Buttons').get_child(i).pressed and timer >= 0.5:
						$Select.play()
						var option_text = $Buttons.get_child(i).get_text()
						if option_text == "Show Positives":
							end_dialogue()
							Global.show_positives()
							
						if !option_text.begins_with(action_prefix):
							EventHub.emit_signal("player_spoke")
						step_forward(i)
			State.HOUSE:
				for i in range(0, get_node("Buttons").get_child_count()):
					if get_node('Buttons').get_child(i).pressed and timer >= 0.5:
						$Select.play()
						
						var option_text = $Buttons.get_child(i).get_text()
						if option_text == "Enter":
							EventHub.emit_signal("house_entered")
						elif option_text == "Exit":
							EventHub.emit_signal("house_exited")
							
						if option_text == "On" or option_text == "Off":
							EventHub.emit_signal("tv_interaction", option_text)
							
						if option_text == "Check reports":
							EventHub.emit_signal("computer_interaction")
							
						if option_text == "Sleep":
							EventHub.emit_signal("bed_interaction")
							
						end_dialogue()


func step_forward(i):
	if i == -1:
		block = parser.next()
	else:
		block = parser.next(block.options[i].key)
	next()
	timer = 0


func init(file_path : String, name := " ", portrait_file := ""):
	Global.active = false
	emit_signal("player_controls_toggle", true)
	text_state = TEXT_STATE.READY
	$PopUp.play()
	EventHub.emit_signal("npc_dialogue")
	state = State.DIALOGUE
	
	if portrait_file != "":
		$Portrait.texture = load(portrait_file)
		$Portrait.show()
	
	$Name_NinePatchRect/Name.text = name
	$Name_NinePatchRect.rect_size.x = $Name_NinePatchRect/Name.get_font("font").get_string_size(name).x + 23
	$Name_NinePatchRect.show()
	$Text.show()
	set_process(true)
	parser.set_format_dictionary({"player_name" : CharacterManager.player["name"], "overlord_day" : Global.overlord_day, "current_day" : Global.day, "days_to_overlord" : Global.days_to_overlord})
	
	file_path = TranslationHub.get_translated_file(file_path)
	
	dialogue_data = parser.open_whiskers(file_path)
	block = parser.start_dialogue(dialogue_data)
	next()


func error():
	$Name_NinePatchRect.hide()
	$Space_NinePatchRect.show()
	show()
	state = State.MESSAGE
	$Text.bbcode_text = "Insufficient Energy"
	set_process(true)
	is_final = true


func next():
	clear_buttons()
	if block:
		show()
		text_state = TEXT_STATE.INPROGRESS
		animate_letters()


func add_button(button_data):
	var node = ChoiceButton.instance()
	node.set_text(button_data.text)
	node.rect_position = Vector2($ChoicePos.position.x, $ChoicePos.position.y + lastBttnPos)
	self.get_node("Buttons").add_child(node)
	
	# Dialogues contains button choices that are coming from Whisker file
	# With focus and using ui_inputs (ui_up, ui_down) it automatically solves the button navigation
	# NOTE: If WASD controls will be remapped, we need to revisit this code.
	if self.get_node("Buttons").get_child_count() == 1:
		var first_button = get_node("Buttons").get_child(0)
		first_button.grab_focus()
	
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
	
	if text_state == TEXT_STATE.INPROGRESS:
		current_button_index = 0
		text_state = TEXT_STATE.COMPLETE
		get_node("Text").visible_characters = -1
		show_buttons()
	else:
		if is_final:
			end_dialogue()
		elif $Buttons.get_child_count() == 0 and state == State.DIALOGUE:
			step_forward(-1)
			$Select.play()


func end_dialogue():
	get_tree().set_input_as_handled()
	reset_characters()
	clear_buttons()
	is_final = false
	set_process(false)
	set_process(false)
	EventHub.emit_signal("dialogue_finished")
	hide()
	Global.active = true
	emit_signal("player_controls_toggle", false)


func update_name(name_in):
	$Name_NinePatchRect/Name.text = name_in
	$Name_NinePatchRect.rect_size.x = $Name_NinePatchRect/Name.get_font("font").get_string_size(name_in).x + 23


func _on_going_in_house_dialogue():
	Global.active = false
	$Portrait.hide()
	$PopUp.play()
	$Text.show()
	update_name("C2 (Home)")
	$Name_NinePatchRect.show()
	$Text.bbcode_text = "Do you want to go inside your house?"
	show()
	$Space_NinePatchRect.hide()
	add_name_button("I have other things to do")
	add_name_button("Enter")
	state = State.HOUSE
	set_process(true)


func _on_going_out_house_dialogue():
	Global.active = false
	$Portrait.hide()
	$PopUp.play()
	$Text.show()
	update_name("Home")
	$Name_NinePatchRect.show()
	$Text.bbcode_text = "Do you want to go outside?"
	show()
	$Space_NinePatchRect.hide()
	add_name_button("Not yet")
	add_name_button("Exit")
	state = State.HOUSE
	set_process(true)


func _on_tv_dialogue(is_on):
	Global.active = false
	$Portrait.hide()
	$PopUp.play()
	$Text.show()
	update_name("TV")
	$Name_NinePatchRect.show()
	$Text.bbcode_text = "Hmmm?"
	show()
	$Space_NinePatchRect.hide()
	if is_on:
		$Text.bbcode_text = " "
		add_name_button("Off")
	else:
		add_name_button("On")
	add_name_button("Do nothing")
	state = State.HOUSE
	set_process(true)

func _on_bed_dialogue():
	Global.active = false
	$Portrait.hide()
	$PopUp.play()
	$Text.show()
	update_name("Bed")
	$Name_NinePatchRect.show()
	$Text.bbcode_text = "Do you want to sleep (skip to next day and regain energy)?"
	if Global.energy > 0:
		$Text.bbcode_text = "Do you want to take a rest? You still have " + str(Global.energy) + " energy left."
	show()
	$Space_NinePatchRect.hide()
	add_name_button("Sleep")
	add_name_button("Let me think")
	state = State.HOUSE
	set_process(true)



func _on_computer_dialogue():
	Global.active = false
	$Portrait.hide()	
	$PopUp.play()
	$Text.show()
	update_name("Computer")
	$Name_NinePatchRect.show()
	$Text.bbcode_text = "What do you want to do?"
	show()
	$Space_NinePatchRect.hide()
	if Global.daily_reports.size() != 0:
		add_name_button("Check reports")
	add_name_button("Do nothing")
	state = State.HOUSE
	set_process(true)


func _on_pet_dialogue():
	print("pet")


func add_name_button(name : String):
	var node = ChoiceButton.instance()
	node.set_text(name)
	node.rect_position = Vector2($ChoicePos.position.x, $ChoicePos.position.y + lastBttnPos)
	self.get_node("Buttons").add_child(node)
	
	# Dialogues contains button choices that are coming from Whisker file
	# With focus and using ui_inputs (ui_up, ui_down) it automatically solves the button navigation
	# NOTE: If WASD controls will be remapped, we need to revisit this code.
	if self.get_node("Buttons").get_child_count() == 1:
		var first_button = get_node("Buttons").get_child(0)
		first_button.grab_focus()
	
	node.show()
	lastBttnPos -= node.rect_size.y + 3


func animate_letters():
	get_node("Text").parse_bbcode(block.text)
	get_node("Text").visible_characters = 0
	current_tick = 0
	$Space_NinePatchRect.show()


func show_buttons():
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


func speech():
	var index = get_node("Text").visible_characters - 1
	var character = get_node("Text").text[index].to_upper()
	if character in ["A", "B", "C","D","E","F","G","H","I","J","K","L","M","N","O","P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]:
		var file_number = character.ord_at(0) - 65 - 1
		var sound_file = Music.letters_sounds[file_number]
		get_node("Speech").stream = sound_file
		get_node("Speech").play()
