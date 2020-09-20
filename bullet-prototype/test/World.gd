extends Node2D

var is_timer_ready = true
var stage_time_now = 0
var stage_time_start = 0
var elapsed_time = 0
var STAGE_TIMER = 61000
var elapsed

func display_stage_time():
	stage_time_now = OS.get_ticks_msec()
	
	elapsed = STAGE_TIMER - (stage_time_now - stage_time_start)
	
	var milliseconds = clamp(elapsed % 1000, 0, 999)
	var seconds = clamp(elapsed / 1000 % 60, 0, 59)
	var minutes = clamp(elapsed / 1000 / 60, 0, 59)
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	
	if milliseconds == 0 and seconds == 0 and minutes == 0:
		is_timer_ready = false
		show_result("Virus - Times Up!")
	else:
		$Timer.text = str_elapsed

func show_result(winner):
	$Path2D/PathFollow2D/Easy.queue_free()
	$Player.queue_free()
	$Winner.text = "Winner: " + winner
	set_process(false)

func _ready():
	$Tween.interpolate_property($Path2D/PathFollow2D, "unit_offset", 0, 1, 30, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _process(delta):
	display_stage_time()
	if $Path2D/PathFollow2D/Easy.health < 0:
		show_result("Player")
	
	if $Player.health < 0:
		show_result("Virus")