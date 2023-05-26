extends Node3D

@export var exit_point: Node3D

func _on_area_3d_body_entered(body):
	if body.is_in_group("players"):
		body.global_position = exit_point.global_position
		body.global_rotation = exit_point.global_rotation
		body.player_teleported.emit()
