extends Control

signal player_controls_toggle
signal show_end_day

func _ready():
	hide()
	
	EventHub.connect("no_energy_left", self, "_on_no_energy_left")


func _on_no_energy_left():
	.show()
	emit_signal("player_controls_toggle", true)


func _on_Close_pressed():
	emit_signal("show_end_day")
	hide()
	pass # Replace with function body.


func _on_EndDay_button_up():
	$AnimationPlayer.play("fade_to_black")
	Music.fade_current()
	EventHub.emit_signal("day_ended")
	pass # Replace with function body.
