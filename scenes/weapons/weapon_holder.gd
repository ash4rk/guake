class_name WeaponHolder

extends Node3D

enum WEAPONS {PISTOL, ASSAULT_RIFLE, SHOTGUN, BAZOOKA, SNIPER_RIFLE}

@export var anim_player: AnimationPlayer
@export var ray_cast: RayCast3D
@export var player: Player

var current_weapon_id: int = 1
var current_weapon: Node: get = _get_current_weapon

@onready var pistol = $Pistol
@onready var assault_rifle = $AssaultRifle
@onready var shotgun = $Shotgun
@onready var bazooka = $Bazooka
@onready var sniper_rifle = $SniperRifle

func _ready():
	update_weapon()

func _input(_event):
	# Using Match?
	if Input.is_action_pressed("get_pistol"):
		current_weapon_id = WEAPONS.PISTOL
		update_weapon()
	if Input.is_action_pressed("get_assault_rifle"):
		current_weapon_id = WEAPONS.ASSAULT_RIFLE
		update_weapon()
	if Input.is_action_pressed("get_shotgun"):
		current_weapon_id = WEAPONS.SHOTGUN
		update_weapon()
	if Input.is_action_pressed("get_bazooka"):
		current_weapon_id = WEAPONS.BAZOOKA
		update_weapon()
	if Input.is_action_pressed("get_sniper_rifle"):
		current_weapon_id = WEAPONS.SNIPER_RIFLE
		update_weapon()
 
func update_weapon():
	for child in get_child_count():
		get_child(child).hide()
		get_child(child).process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_child(current_weapon_id).show()
	get_child(current_weapon_id).process_mode = Node.PROCESS_MODE_INHERIT
	player.emit_signal("displayed_ammo_changed", current_weapon.ammo)

func _on_weapon_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")

func _get_current_weapon():
	return get_child(current_weapon_id)
