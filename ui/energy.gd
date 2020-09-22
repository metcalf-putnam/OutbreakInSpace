extends Node2D


func _ready():
	EventHub.connect("energy_used", self, "update_energy")
	update_sprites()

func update_energy():
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
