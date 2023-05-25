class_name Pickup

extends Node3D

@export var lifetime: float = 0.0
@export var is_respawnable: bool = false
@export var respawn_time: float = 0.0

@onready var collision: CollisionShape3D = $Area3D/CollisionShape3D

func on_pickup(_player: Player):
	pass

@rpc("any_peer")
func _on_timer_timeout():
	visible = true
	collision.call_deferred("set_disabled", false)

@rpc("any_peer")
func _on_area_3d_body_entered(body):
	if !body.is_in_group("players"):
		return
		
	on_pickup(body)
	if is_respawnable:
		visible = false
		collision.call_deferred("set_disabled", true)
		$RespawnTimer.start(respawn_time)
	else:
		queue_free()
