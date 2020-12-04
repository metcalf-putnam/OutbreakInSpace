extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	show_glow(false)
	EventHub.connect("no_testables_in_range", self, "_on_no_testables_in_range")
	EventHub.connect("testable_character_in_range", self, "_on_testable_character_in_range")


func _on_no_testables_in_range():
	show_glow(false)


func _on_testable_character_in_range():
	show_glow(true)


func show_glow(boolean):
	if boolean:
		$Glow.show()
	else:
		$Glow.hide()
