extends CharacterBody3D

@onready var camera_pivot = get_tree().get_nodes_in_group("PlayerCharacter")[1]
@export var _rotation_speed : float = TAU

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var _theta : float


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_right", "move_left", "move_down", "move_up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# Handle character rotation to look in the direction of movement
		_theta = wrapf(atan2(input_dir.x, input_dir.y) - rotation.y, -PI, PI)
		rotation.y += clamp(_rotation_speed * delta, 0, abs(_theta)) * sign(_theta)
		# Movement is 3D, sure, but we treat it as if it's 2D so as not to bork rotation etc.
		# Otherwise, when character rotates, velocity is relative to how they're facing
		# TODO No it's not lolol
		velocity.x = input_dir.x * SPEED
		velocity.z = input_dir.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
