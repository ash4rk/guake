extends Node3D

class_name Weapon

@export var damage: int
@export var ammo: int
@export var max_ammo: int
@export var spare_ammo: int
@export var ammo_per_shot: int
@export var full_auto: bool
@export var reload_time: float
@export var firerate: float
@export var shotgun : bool
@export var ray_cast: RayCast3D
@export var anim_player: AnimationPlayer

var vertical_recoil : int = 0
var can_fire = true
var is_reloading = false

func _ready(): 
	randomize()

func fire(_delta):
	pass

func reload():
	is_reloading = true
	can_fire = false
	$AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	if is_reloading == true:
		var ammo_to_add = min(max_ammo - ammo, spare_ammo)
		ammo += ammo_to_add
		spare_ammo -= ammo_to_add
	if ammo > 0:
		can_fire = true
	is_reloading = false

