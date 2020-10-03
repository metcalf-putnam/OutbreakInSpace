extends Area2D

export var label_text : String


func _ready():
	$Label.hide()
	$Label.text = label_text


func _on_DumbSign_body_entered(body):
	if body.is_in_group("player"):
		$Label.show()


func _on_DumbSign_body_exited(body):
	if body.is_in_group("player"):
		$Label.hide()
