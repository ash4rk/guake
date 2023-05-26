class_name HealthPickup

extends Pickup

@export var HEAL_VALUE: int = 50

func on_pickup(player: Player):
	player.heal(HEAL_VALUE)
	$AudioStreamPlayer3D.play()
