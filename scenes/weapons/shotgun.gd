class_name Shotgun

extends Weapon

@export var ray_container: Node3D
@export var spread = 1
@export var shotgun_spread = 0.05

func _process(delta):
	if not is_multiplayer_authority(): return
	if player.is_dead: return
	
	if is_reloading:
		pass
	if ammo <= 0 and !is_reloading:
		can_fire = false
		reload()
	if Input.is_action_pressed("shoot") and can_fire:
		fire(delta)

func fire(_delta):
	
	play_shoot_effects.rpc()
	
	can_fire = false
	ammo -= ammo_per_shot
	for r in ray_container.get_children():

		r.rotation_degrees.x = rad_to_deg(randf_range(shotgun_spread, -shotgun_spread))
		r.rotation_degrees.z = rad_to_deg(randf_range(shotgun_spread, -shotgun_spread))
		
		await get_tree().create_timer(0.01).timeout
		
		r.rotation_degrees.x = 0
		r.rotation_degrees.z = 0
	
		if r.get_collider() != null and r.get_collider().is_in_group("players"):
			var hit_player = r.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority(), damage, self.global_position)
			_play_blood_particles.rpc(r.get_collision_point())
			$OnHitAudioStreamPlayer.play()
			
		if r.is_colliding():
			_place_decal.rpc(r.get_collision_point())
			
	await get_tree().create_timer(firerate).timeout
		
	if not is_reloading:
		can_fire = true
	super(_delta)
