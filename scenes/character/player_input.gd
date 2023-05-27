extends MultiplayerSynchronizer

@export var camera : Camera3D
@export var is_jumping := false
@export var input_dir = Vector3()
@export var is_dead: bool = false

func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	is_jumping = true

func _process(_delta):
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------
	
	if is_dead: return

	# ----------------------------------
	# Walking
	var direction = Input.get_vector("left", "right", "backward", "forward")
	direction = direction.normalized()
	
	input_dir = Vector3()
	var cam_xform = camera.get_global_transform()

	# Basis vectors are already normalized.
	input_dir += -cam_xform.basis.z * direction.y
	input_dir += cam_xform.basis.x * direction.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	# ----------------------------------
