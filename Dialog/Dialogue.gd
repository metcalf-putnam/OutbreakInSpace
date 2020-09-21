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

func _ready():
	set_process(false)
	hide()
	EventHub.connect("new_dialogue", self, "init")


func _process(delta):
	# TODO: get this out of process for speed improvements
	timer += delta
	for i in range(0, get_node("Buttons").get_child_count()):
		if get_node('Buttons').get_child(i).pressed and timer >= 0.5:
			var option_text = $Buttons.get_child(i).get_text()
			if !option_text.begins_with(action_prefix):
				EventHub.emit_signal("player_spoke", len(option_text))
			step_forward(i)

func step_forward(i):
	if i == -1:
		block = parser.next()
	else:
		block = parser.next(block.options[i].key)
	next()
	timer = 0


func init(file_path : String, name := " "):
	
	$Name_NinePatchRect/Name.text = name
	set_process(true)
	parser = WhiskersParser.new(Global)
	parser.set_format_dictionary({"player_name" : "Knuthl"})
	dialogue_data = parser.open_whiskers(file_path)
	block = parser.start_dialogue(dialogue_data)
	next()


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


func _unhandled_input(event):
	if !is_processing():
		return
	if !event.is_action_pressed("ui_accept"):
		return
	if is_final:
		get_tree().set_input_as_handled()
		is_final = false
		set_process(false)
		EventHub.emit_signal("dialogue_finished")
		hide()
	elif $Buttons.get_child_count() == 0:
		step_forward(-1)
