extends CharacterBody3D

@onready var camera_pivot = get_tree().get_nodes_in_group("Player")[1]
@export var _rotation_speed : float = TAU
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SPEED = 0.1
const JUMP_VELOCITY = 4.5

func _ready():
	self.set_meta("player", true)

	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	# Get movement input
	var input_dir := Input.get_vector("move_right", "move_left", "move_down", "move_up")
	
	# If there is movement input, determine movement direction
	if input_dir.length() > 0:
		var move_dir = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		transform.origin -= move_dir * SPEED

		# Calculate target rotation based on movement direction
		var target_rotation = atan2(-move_dir.x, -move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, _rotation_speed * delta)

		# Play running animation
		animation_player.play("Running_B")
	else:
		animation_player.play("Idle")
		
	move_and_slide()
	
func die():
	print("Player has died! Resetting...")
	# TODO Implement animations, checkpoints, keep state upon reload, general death logic. This just 
	# re-instantiates the scene you're in.
	# TODO You'll fix this when making an actual death function but player respawns with no health, gotta
	# re-instantiate the state machine most likely unless there's a built in way
	get_tree().reload_current_scene()
