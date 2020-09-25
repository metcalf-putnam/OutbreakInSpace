extends CanvasLayer
var report_title := "[wave]Daily Report[/wave]"
var new_infections_label := "New infections: "
var total_infections_label := "Total infections: "
var test_label := "Test Results:[N/A: not yet implemented]"

func _ready():
	get_tree().paused = true
	var textbox = $NinePatchRect/RichTextLabel
	textbox.clear()
	textbox.append_bbcode(report_title) 
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode(new_infections_label + str(Global.new_infections))
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode(total_infections_label + str(Global.total_infections))
	textbox.newline()
	textbox.newline()
	textbox.append_bbcode(test_label)
	
	Global.new_infections = 0

func _input(event):
	if !event.is_action_pressed("ui_accept"):
		return
	get_tree().paused = false
	queue_free()
	
