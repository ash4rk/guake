extends Node3D

@export var force: float = 30.0

func _on_area_3d_body_entered(body):
	if body.is_in_group("players"):
		body.velocity = get_global_transform().basis.y * force
		$AudioStreamPlayer3D.play()
