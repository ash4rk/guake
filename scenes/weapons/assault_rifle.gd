extends Weapon

@onready var DECAL_SCENE = preload("res://scenes/weapons/bullet_hole_decal.tscn")
@onready var BLOOD_PARTICLES_SCENE = preload("res://scenes/particles/blood_particles.tscn")

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

@rpc("call_local")
func _place_decal(point: Vector3):
	var decal = DECAL_SCENE.instantiate()
	get_tree().get_root().add_child(decal)
	decal.global_transform.origin = point
	var tween = get_tree().create_tween()
	tween.tween_interval(3)
	tween.tween_callback(func():decal.free())

@rpc("call_local")
func _play_blood_particles(point: Vector3):
	var blood_particles = BLOOD_PARTICLES_SCENE.instantiate()
	get_tree().get_root().add_child(blood_particles)
	blood_particles.global_transform.origin = point
	var tween = get_tree().create_tween()
	tween.tween_interval(3)
	tween.tween_callback(func():blood_particles.free())

@rpc("call_local")
func play_shoot_effects():
	anim_player.stop(true)
	anim_player.play("shoot")
	$MuzzleFlash.restart()
	$MuzzleFlash.emitting = true
	$AudioStreamPlayer3D.play()
