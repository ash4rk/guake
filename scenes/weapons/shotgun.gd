class_name Shotgun

extends Weapon

func _process(delta):
	if not is_multiplayer_authority(): return
	if player.is_dead: return
	
	if is_reloading:
		pass
	if ammo <= 0 and !is_reloading:
		can_fire = false
		$ReloadAudioStreamPlayer3D.play()
		reload()
	if Input.is_action_pressed("shoot") and can_fire:
		fire(delta)

func fire(_delta):
	play_shoot_effects.rpc()
	can_fire = false
	ammo -= ammo_per_shot
	if ray_cast.get_collider() != null and ray_cast.get_collider().is_in_group("players"):
		var hit_player = ray_cast.get_collider()
		hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority(), damage, self.global_position)
		_play_blood_particles.rpc(ray_cast.get_collision_point())
		$OnHitAudioStreamPlayer.play()

	await get_tree().create_timer(firerate).timeout
	if ray_cast.is_colliding():
		_place_decal.rpc(ray_cast.get_collision_point())

	if not is_reloading:
		can_fire = true
	super(_delta)
