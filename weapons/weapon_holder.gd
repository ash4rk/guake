extends Node3D

enum WEAPONS {PISTOL, ASSAULT_RIFLE, SHOTGUN, BAZOOKA, SNIPER_RIFLE}

@export var anim_player: AnimationPlayer

var current_weapon = 1

func _input(_event):
	# Using Match?
	if Input.is_action_pressed("get_pistol"):
		current_weapon = WEAPONS.PISTOL
	if Input.is_action_pressed("get_assault_rifle"):
		current_weapon = WEAPONS.ASSAULT_RIFLE
	if Input.is_action_pressed("get_shotgun"):
		current_weapon = WEAPONS.SHOTGUN
	if Input.is_action_pressed("get_bazooka"):
		current_weapon = WEAPONS.BAZOOKA
	if Input.is_action_pressed("get_sniper_rifle"):
		current_weapon = WEAPONS.SNIPER_RIFLE
	weapon_switch()

func _ready():
	for child in get_child_count():
		get_child(child).hide()
		get_child(child).process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_child(current_weapon).show()
	get_child(current_weapon).process_mode = Node.PROCESS_MODE_INHERIT
 
func weapon_switch():
	for child in get_child_count():
		get_child(child).hide()
		get_child(child).process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_child(current_weapon).show()
	get_child(current_weapon).process_mode = Node.PROCESS_MODE_INHERIT

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")

