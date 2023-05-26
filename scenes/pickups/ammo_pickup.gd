extends Pickup

@export var AMMO_VALUE: int = 5
@export var WEAPON_ID: int = WeaponHolder.WEAPONS.ASSAULT_RIFLE

func on_pickup(player: Player):
	player.gain_ammo(WEAPON_ID, AMMO_VALUE)
	$AudioStreamPlayer3D.play()
