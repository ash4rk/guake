extends Node

@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var health_label = $CanvasLayer/HUD/HBoxContainer/HealthLabel
@onready var ammo_label = $CanvasLayer/HUD/HBoxContainer/HBoxContainer/AmmoLabel
@onready var spare_ammo_label = $CanvasLayer/HUD/HBoxContainer/HBoxContainer/SpareAmmoLabel
@onready var hud_anim_player = $CanvasLayer/HUD/AnimationPlayer

const Player = preload("res://scenes/character/player.tscn")
const PORT = 4242
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	$CanvasLayer/MainMenu.start_client.connect(_on_start_client)
	$CanvasLayer/MainMenu.start_server.connect(_on_start_server)
	$CanvasLayer/MainMenu.start_offline.connect(_on_start_offline)
	if OS.get_cmdline_user_args().has("--server"):
		_on_start_server()

func _on_start_client(ip_address: String):
	enet_peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = enet_peer
	$CanvasLayer/HUD.visible = true

func _on_start_server():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	$ServerCam.current = true

func add_player(peer_id):
	var player = Player.instantiate()
	player.player = peer_id
	player.call_deferred("set_position", Vector3.ZERO)
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_ui(health_value):
	if int(health_label.text) > health_value:
		hud_anim_player.play("blood_on_screen")
	else:
		hud_anim_player.play("green_tint_flash")
	
	if health_value <= 0:
		hud_anim_player.stop()
		hud_anim_player.play("red_tint_fill")
	
	health_bar.value = health_value
	health_label.text = str(health_value)

func update_ammo_ui(ammo_value = -1, spare_ammo_value = -1):
	ammo_label.text = str(ammo_value)
	spare_ammo_label.text = str(spare_ammo_value)

func _on_got_ammo():
	hud_anim_player.play("yellow_tint_flash")

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_ui)
		node.displayed_ammo_changed.connect(update_ammo_ui)
		node.player_teleported.connect(_on_player_teleported)
		node.got_ammo.connect(_on_got_ammo)

func _on_death_area_3d_body_entered(body):
	body.kill()
	$DeathArea3D/FallAudioStreamPlayer.play()

func _on_player_teleported():
	hud_anim_player.play("blue_tint_flash")

func _on_start_offline():
	add_player("1")
	$CanvasLayer/HUD.visible = true
