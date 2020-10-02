extends CanvasLayer

var current_report_id = 0
func _ready():
	get_tree().paused = true
	current_report_id = Global.daily_reports.size() - 1
	
	if current_report_id == 0:
		$NinePatchRect/PrevButton.hide()
		$NinePatchRect/NextButton.hide()
	
	if current_report_id > 0:
		$NinePatchRect/NextButton/NextButton.disabled = true
	
	load_report()


func _input(event):
	if !event.is_action_pressed("ui_accept"):
		return
	EventHub.emit_signal("dialogue_finished")
	get_tree().paused = false
	queue_free()


func load_report():
	
	$NinePatchRect/PrevButton/PrevButton.disabled = current_report_id == 0
	$NinePatchRect/NextButton/NextButton.disabled = (current_report_id + 1) == Global.daily_reports.size()
	
	var textbox = $NinePatchRect/RichTextLabel
	textbox.bbcode_text = Global.daily_reports[current_report_id]


func _on_PrevButton_pressed():
	current_report_id -= 1
	load_report()


func _on_NextButton_pressed():
	current_report_id += 1
	load_report()
