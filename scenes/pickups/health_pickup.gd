extends Pickup

@export var HEAL_VALUE: int = 5

func on_pickup(player: Player):
	player.heal(HEAL_VALUE)
