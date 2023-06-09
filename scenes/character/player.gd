extends CharacterBody3D

class_name Player

signal health_changed(health_value)
signal displayed_ammo_changed(ammo_value, spare_ammo_value)
signal player_teleported()
signal got_ammo()

# Movement
const GRAVITY = -24.8
const MAX_SPEED = 17
const JUMP_SPEED = 10
const ACCEL = 4.5
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05

# Stats
const MAX_HEALTH: int = 100
var is_dead: bool = false : set = _set_is_dead

# Movement
@onready var camera: Camera3D = $RotationHelper/PlayerEyes
@onready var rotation_helper: Node3D = $RotationHelper
var jumper_velocity: = Vector3.ZERO

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
# Player synchronized input.
@onready var input = $PlayerInput

# Components
@onready var char_mesh: MeshInstance3D = $Armature/Skeleton3D/LowPolyNormalMan
@onready var weapon_holder: WeaponHolder = $RotationHelper/PlayerEyes/WeaponHolder
@onready var ray_cast: RayCast3D = $RotationHelper/PlayerEyes/RayCast3D
@onready var crosshair: ColorRect = $CanvasLayer/Crosshair
var health = MAX_HEALTH

# TODO: Abolish full Player authority, give authority only for inputs
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	$AnimationTree.active = true
	if not is_multiplayer_authority():
		return
	char_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	_process_movement(delta)
	_process_animation()
	_process_hud()


func _process_movement(delta):
	input.input_dir.y = 0
	input.input_dir = input.input_dir.normalized()

	# Add the gravity
	velocity.y += delta * GRAVITY
	
	# Handle jump and reset jump state
	if input.is_jumping and is_on_floor():
		velocity.y = JUMP_SPEED
	input.is_jumping = false
	
	var hvel = velocity
	hvel.y = 0

	var target = input.input_dir
	target *= MAX_SPEED

	var accel
	if input.input_dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.lerp(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	# Impact jumper velocity and reset it
	velocity += jumper_velocity
	jumper_velocity = Vector3.ZERO
	
	move_and_slide()

func _process_animation():
	$AnimationTree.set("parameters/conditions/is_dead", is_dead)
	$AnimationTree.set("parameters/conditions/idle", input.input_dir == Vector3.ZERO and !is_dead)
	$AnimationTree.set("parameters/conditions/walk", input.input_dir != Vector3.ZERO and !is_dead)

func _process_hud():
	if not is_multiplayer_authority():
		return
	var cursor_object = ray_cast.get_collider()
	if cursor_object == null:
		crosshair.material.set("shader_parameter/color_id", 0)
	elif cursor_object.is_in_group("players"):
		crosshair.material.set("shader_parameter/color_id", 1)
	else:
		crosshair.material.set("shader_parameter/color_id", 0)
	
	crosshair.material.set("shader_parameter/spread", velocity.length()/20 + 1)

func _input(event):
	if not is_multiplayer_authority(): return
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -89, 89)
		rotation_helper.rotation_degrees = camera_rot

func _handle_death(from_death):
	is_dead = true
	jumper_velocity = -(from_death - global_position).normalized() * 150
	weapon_holder.hide()
	$FullPlayerShape.rotation.x = deg_to_rad(90)
	$DeathAudioStreamPlayer.play()

func _revive():
	position = Vector3.ZERO
	is_dead = false
	weapon_holder.show()
	heal(MAX_HEALTH)
	$FullPlayerShape.rotation = Vector3.ZERO
	$ReviveAudioStreamPlayer3D.play()
func _set_is_dead(value):
	is_dead = value
	input.is_dead = value

@rpc("any_peer")
func receive_damage(damage_value: int = 1, from: Vector3 = Vector3.ZERO):
	if is_dead: return
	
	health -= damage_value
	health_changed.emit(health)
	if health <= 0:
		_handle_death(from)
		await get_tree().create_timer(6.0).timeout
		_revive()

func kill():
	receive_damage(health)

@rpc("any_peer")
func heal(value: int):
	var new_health = min(MAX_HEALTH, value + health)
	health = new_health
	health_changed.emit(health)

@rpc("any_peer")
func gain_ammo(weapon_id : int, value):
	# TODO: Refactor to oneliner
	match weapon_id:
		WeaponHolder.WEAPONS.PISTOL:
			weapon_holder.pistol.spare_ammo += value
		WeaponHolder.WEAPONS.ASSAULT_RIFLE:
			weapon_holder.assault_rifle.spare_ammo += value
		WeaponHolder.WEAPONS.SHOTGUN:
			weapon_holder.shotgun.spare_ammo += value
		WeaponHolder.WEAPONS.BAZOOKA:
			weapon_holder.bazooka.spare_ammo += value
		WeaponHolder.WEAPONS.SNIPER_RIFLE:
			weapon_holder.sniper_rifle.spare_ammo += value
	weapon_holder.update_weapon()
	got_ammo.emit()
