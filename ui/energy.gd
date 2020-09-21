extends Node2D


func _ready():
	EventHub.connect("energy_used", self, "decrement_energy")
	update_sprites()

func decrement_energy():
	if Global.energy <= 0:
		print("error: trying to use energy that doesn't exist")
		return
	Global.energy -= 1
	update_sprites()


func update_sprites():
	var count = 0
	
	for i in range(Global.energy):
		$Sprites.get_child(i).visible = true
		count += 1
	
	if $Sprites.get_child_count() > Global.energy:
		while count < $Sprites.get_child_count():
			$Sprites.get_child(count).visible = false
			count += 1
