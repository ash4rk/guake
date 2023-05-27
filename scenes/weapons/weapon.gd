extends Node3D

class_name Weapon

@export var damage: int
@export var ammo: int
@export var max_ammo: int
@export var spare_ammo: int
@export var ammo_per_shot: int
@export var reload_time: float
@export var firerate: float

@onready var weapon_holder: WeaponHolder = get_parent()
@onready var ray_cast: RayCast3D = weapon_holder.ray_cast
@onready var anim_player: AnimationPlayer = weapon_holder.anim_player
@onready var player: Player = weapon_holder.player

var can_fire = true
var is_reloading = false

func _ready(): 
	randomize()

func fire(_delta):
	player.emit_signal("displayed_ammo_changed", ammo)

# Not yet in use
func reload():
	is_reloading = true
	can_fire = false
#	$AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	if is_reloading == true:
		var ammo_to_add = min(max_ammo - ammo, spare_ammo)
		ammo += ammo_to_add
		spare_ammo -= ammo_to_add
	if ammo > 0:
		can_fire = true
	is_reloading = false
	player.emit_signal("displayed_ammo_changed", ammo)

