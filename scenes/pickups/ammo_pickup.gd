extends Pickup

@export var AMMO_VALUE: int = 5
@export var WEAPON_ID: int = WeaponHolder.WEAPONS.ASSAULT_RIFLE

func _ready():
	match WEAPON_ID:
		WeaponHolder.WEAPONS.SHOTGUN:
			$AmmoPickupMesh.material_override = $AmmoPickupMesh.material_override.duplicate()
			$AmmoPickupMesh.material_override.albedo_color = Color.CORAL
			$SpotLight3D.light_color = Color.CORAL

			
func on_pickup(player: Player):
	player.gain_ammo(WEAPON_ID, AMMO_VALUE)
	$AudioStreamPlayer3D.play()
