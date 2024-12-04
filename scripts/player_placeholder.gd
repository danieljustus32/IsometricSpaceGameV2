extends CharacterBody3D

@onready var camera_pivot = get_tree().get_nodes_in_group("PlayerCharacter")[1]
@export var _rotation_speed : float = TAU
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SPEED = 0.1
const JUMP_VELOCITY = 4.5
var _theta : float


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var forward = camera_pivot.transform.basis.z.normalized() * SPEED
	if Input.is_action_pressed("move_up"):
		transform.origin += -forward
		animation_player.play("Running_B")
	if Input.is_action_pressed("move_down"):
		transform.origin += forward
	if Input.is_action_pressed("move_right"):
		transform.origin += -forward.cross(Vector3.UP) / 1.5
		animation_player.play("Running_Strafe_Right")
	if Input.is_action_pressed("move_left"):
		transform.origin += forward.cross(Vector3.UP) / 1.5
		animation_player.play("Running_Strafe_Left")
	elif not Input.is_anything_pressed():
	# Player is idle
		animation_player.play("Idle")
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# Which has been done :D
	# TODO handle gamepads and mobile devices
	var input_dir := Input.get_vector("move_right", "move_left", "move_down", "move_up")

		# Handle character rotation to look in the direction of movement
	# _theta = wrapf(atan2(input_dir.x, input_dir.y) - rotation.y, -PI, PI)
	# rotation.y += clamp(_rotation_speed * delta, 0, abs(_theta)) * sign(_theta)
	move_and_slide()
