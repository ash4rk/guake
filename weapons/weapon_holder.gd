extends Node3D

enum WEAPONS {PISTOL, ASSAULT_RIFLE, SHOTGUN, BAZOOKA, SNIPER_RIFLE}

@export var anim_player: AnimationPlayer

var current_weapon = 1

func _ready():
	weapon_switch()

func _input(_event):
	# Using Match?
	if Input.is_action_pressed("get_pistol"):
		current_weapon = WEAPONS.PISTOL
		weapon_switch()
	if Input.is_action_pressed("get_assault_rifle"):
		current_weapon = WEAPONS.ASSAULT_RIFLE
		weapon_switch()
	if Input.is_action_pressed("get_shotgun"):
		current_weapon = WEAPONS.SHOTGUN
		weapon_switch()
	if Input.is_action_pressed("get_bazooka"):
		current_weapon = WEAPONS.BAZOOKA
		weapon_switch()
	if Input.is_action_pressed("get_sniper_rifle"):
		current_weapon = WEAPONS.SNIPER_RIFLE
		weapon_switch()
 
func weapon_switch():
	for child in get_child_count():
		get_child(child).hide()
		get_child(child).process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_child(current_weapon).show()
	get_child(current_weapon).process_mode = Node.PROCESS_MODE_INHERIT

func _on_weapon_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
