extends Node3D

class_name Weapon

@onready var DECAL_SCENE = preload("res://scenes/weapons/bullet_hole_decal.tscn")
@onready var BLOOD_PARTICLES_SCENE = preload("res://scenes/particles/blood_particles.tscn")

@export var damage: int
@export var ammo: int
@export var max_ammo: int
@export var spare_ammo: int
@export var ammo_per_shot: int
@export var reload_time: float
@export var firerate: float

@onready var weapon_holder: WeaponHolder = get_parent()
@onready var ray_cast: RayCast3D = weapon_holder.ray_cast
@onready var weapon_holder_anim_player: AnimationPlayer = weapon_holder.anim_player
@onready var weapon_anim_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = weapon_holder.player

var can_fire = true
var is_reloading = false

func _ready(): 
	randomize()

func fire(_delta):
	player.emit_signal("displayed_ammo_changed", ammo, spare_ammo)

func reload():
	$ReloadAudioStreamPlayer3D.play()
	is_reloading = true
	can_fire = false
	weapon_anim_player.stop(true)
	weapon_anim_player.play("reload")
	await get_tree().create_timer(reload_time).timeout
	if is_reloading == true:
		var ammo_to_add = min(max_ammo - ammo, spare_ammo)
		ammo += ammo_to_add
		spare_ammo -= ammo_to_add
	if ammo > 0:
		can_fire = true
	is_reloading = false
	player.emit_signal("displayed_ammo_changed", ammo, spare_ammo)

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
	# TODO: Get rid of weapon_holder "shoot" anim
	# make unique "shoot" anims in weapon_anim_player
	# use weapon_holder_anim_player only for weapon switch
	# (or even put weapon switch anims in a weapon_anim_player.)
	weapon_holder_anim_player.stop(true)
	weapon_holder_anim_player.play("shoot")
	
	weapon_anim_player.stop(true)
	weapon_anim_player.play("shoot")
