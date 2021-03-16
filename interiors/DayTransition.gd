extends CanvasLayer

const TITLE_FORMAT = "Day %s"
const OVERLORD_REMINDER_FORMAT = "%s Days until Overlord comes..."

onready var title = $Title
onready var subtitle = $Subtitle
onready var overload_reminder = $OverlordReminder
onready var anim = $AnimationPlayer

signal day_transitioned

func show_transition():
	#	get day transition details containing title and subtitle
	
	title.text = TITLE_FORMAT % [Global.day]
	subtitle.text = OVERLORD_REMINDER_FORMAT % [Global.days_to_overlord]
	#title.text = TITLE_FORMAT % [Global.day, "<Title for this Day Maybe?>"]
	#subtitle.text = "<maybe a subtitle here?>"
	#overload_reminder.text = OVERLORD_REMINDER_FORMAT % [Global.days_to_overlord]
	anim.play("show")


func _on_AnimationPlayer_animation_finished(anim_name):
	Global.day_transitioned = true
	emit_signal("day_transitioned")
	queue_free()
	pass # Replace with function body.
