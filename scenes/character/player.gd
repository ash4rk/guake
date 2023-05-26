extends CharacterBody3D

class_name Player

signal health_changed(health_value)
signal ammo_changed(ammo_value)
signal player_teleported()

# Movement
const GRAVITY = -24.8
const MAX_SPEED = 20
const JUMP_SPEED = 10
const ACCEL = 4.5
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05

# Stats
const MAX_HEALTH: int = 30
var is_dead: bool = false

# Movement
var input_dir = Vector3()
@onready var camera: Camera3D = $RotationHelper/PlayerEyes
@onready var rotation_helper: Node3D = $RotationHelper
var jumper_velocity: = Vector3.ZERO
# Stats
@onready var weapon_holder: WeaponHolder = $RotationHelper/PlayerEyes/WeaponHolder
var health = 3

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		$Armature.show()
		return

	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	_process_input(delta)
	_process_movement(delta)
	_process_animation()

func _process_input(_delta):
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------
	
	if is_dead: return

	# ----------------------------------
	# Walking
	input_dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	input_dir += -cam_xform.basis.z * input_movement_vector.y
	input_dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
	# ----------------------------------

func _process_movement(delta):
	input_dir.y = 0
	input_dir = input_dir.normalized()

	velocity.y += delta * GRAVITY

	var hvel = velocity
	hvel.y = 0

	var target = input_dir
	target *= MAX_SPEED

	var accel
	if input_dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.lerp(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	velocity += jumper_velocity
	
	move_and_slide()
	jumper_velocity = Vector3.ZERO

func _process_animation():
	$AnimationTree.set("parameters/conditions/idle", input_dir == Vector3.ZERO)
	$AnimationTree.set("parameters/conditions/walk", input_dir != Vector3.ZERO)

func _input(event):
	if not is_multiplayer_authority(): return
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func _handle_death(from_death):
	is_dead = true
	jumper_velocity = -(from_death - global_position).normalized() * 150
	weapon_holder.hide()

func _revive():
	position = Vector3.ZERO
	is_dead = false
	weapon_holder.show()
	heal(MAX_HEALTH)

@rpc("any_peer")
func receive_damage(from: Vector3 = Vector3.ZERO):
	if is_dead: return
	
	health -= 1
	health_changed.emit(health)
	if health <= 0:
		_handle_death(from)
		await get_tree().create_timer(6.0).timeout
		_revive()


@rpc("any_peer")
func heal(value: int):
	var new_health = min(MAX_HEALTH, value + health)
	health = new_health
	health_changed.emit(health)

@rpc("any_peer")
func gain_ammo(weapon_id : int, value):
	match weapon_id:
		WeaponHolder.WEAPONS.PISTOL:
			weapon_holder.pistol.ammo += value
			ammo_changed.emit(weapon_holder.pistol.ammo)
		WeaponHolder.WEAPONS.ASSAULT_RIFLE:
			weapon_holder.assault_rifle.ammo += value
			ammo_changed.emit(weapon_holder.assault_rifle.ammo)
		WeaponHolder.WEAPONS.SHOTGUN:
			weapon_holder.shotgun.ammo += value
			ammo_changed.emit(weapon_holder.shotgun.ammo)
