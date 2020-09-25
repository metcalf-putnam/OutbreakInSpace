extends CanvasLayer
var report_title := "[wave]Daily Report[/wave]"
var new_infections_label := "New infections: "
var total_infections_label := "Total infections: "
var test_label := "[wave]Test Results:[/wave]"

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
	if Global.test_results.has(Global.day):
		for result in Global.test_results[Global.day]:
			textbox.newline()
			textbox.append_bbcode(result)
	else:
		textbox.append_bbcode("N/A")
	
	Global.new_infections = 0

func _input(event):
	if !event.is_action_pressed("ui_accept"):
		return
	get_tree().paused = false
	queue_free()
	
