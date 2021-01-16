extends NinePatchRect

const SHOW_LOGS_TEXT = "Show Logs"
const HIDE_LOGS_TEXT = "Hide Logs"

onready var show_hide_logs_btn_lbl = $ShowHideLogsBtn/Label
onready var anim = $AnimationPlayer

var current_log_count = 0

func _ready():
	$Logs.scroll_following = true

func _process(delta):
	var new_log_count = Logger.get_log_count()
	if current_log_count == new_log_count:
		return
	
	var prev_log_count = current_log_count
	current_log_count = new_log_count
	
	var new_logs = Logger.get_logs()
	var new_logs_size = new_logs.size()
	
	while prev_log_count < new_logs_size:
		$Logs.append_bbcode(new_logs[prev_log_count])
		prev_log_count += 1


func _on_TextureButton_pressed():
	
	if show_hide_logs_btn_lbl.text == SHOW_LOGS_TEXT:
		anim.play("show")
	else:
		anim.play_backwards("show")
	pass # Replace with function body.
