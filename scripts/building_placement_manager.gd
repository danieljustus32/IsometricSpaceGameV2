extends Node3D

@export var grid_size: float = 1.0  # Grid-based placement (1m x 1m)
@export var placement_offset: float = 10.0  # Initial distance in front of player
@export var update_rate: float = 0.1  # How often to update position (in seconds)

@onready var player: CharacterBody3D = StateMachine.player
@onready var camera_pivot: Node3D = StateMachine.camera_pivot

var selected_building_scene: PackedScene
var ghost_building: Node3D  # Temporary preview before placement
var is_placing_building = false  
var ghost_position: Vector3  # Position for manual movement
var move_input: Vector2 = Vector2.ZERO  # Stores last movement input
var rotation_angle: float = 0.0  # Tracks current rotation of the building
var is_rotating = false  # Track if rotation is ongoing

var move_timer: Timer
var tween: Tween

func _ready():
	SignalBus.building_selected.connect(_on_building_selected)

	# Create Timer for movement updates
	move_timer = Timer.new()
	move_timer.wait_time = update_rate
	move_timer.autostart = false
	move_timer.one_shot = false
	move_timer.timeout.connect(_update_ghost_position)
	add_child(move_timer)

func _on_building_selected(building_scene: PackedScene):
	if is_placing_building:
		return  

	is_placing_building = true
	get_viewport().gui_release_focus()

	if ghost_building:
		ghost_building.queue_free()

	selected_building_scene = building_scene
	ghost_building = selected_building_scene.instantiate()
	ghost_building.set_collision_layer_value(1, false)

	add_child(ghost_building)

	# Initialize position in front of player
	var forward_dir = player.global_transform.basis.z
	ghost_position = player.global_transform.origin + forward_dir * placement_offset
	ghost_position.y = 0.5  
	rotation_angle = 0.0  # Reset rotation when selecting a new building
	_update_ghost_position()

	player.set_physics_process(false)
	camera_pivot.set_process(false)
	move_timer.start()  # Start movement update timer

func _process(delta):
	if not ghost_building:
		return

	# Capture movement input but only apply it at set intervals
	move_input = Input.get_vector("move_right", "move_left", "move_down", "move_up")

	# Check for rotation inputs
	if Input.is_action_just_pressed("rotate_camera_right"):
		rotation_angle -= 90.0
		_update_ghost_rotation()

	if Input.is_action_just_pressed("rotate_camera_left"):
		rotation_angle += 90.0
		_update_ghost_rotation()

	if Input.is_action_just_pressed("confirm_building"):
		place_building()

	if Input.is_action_just_pressed("cancel_building"):
		cancel_building()
		
	if is_rotating and ghost_building:
		# Perform smooth interpolation every frame
		var current_rotation_rad = deg_to_rad(ghost_building.rotation_degrees.y)
		var target_rotation_rad = deg_to_rad(rotation_angle)

		# Lerp towards target
		var new_rotation_rad = lerp_angle(current_rotation_rad, target_rotation_rad, 5.0 * delta)

		# Apply new rotation
		ghost_building.rotation_degrees.y = rad_to_deg(new_rotation_rad)

		# Stop rotating if close enough to target
		if abs(ghost_building.rotation_degrees.y - rotation_angle) < 0.1:
			ghost_building.rotation_degrees.y = rotation_angle
			is_rotating = false  # Stop further updates

func _update_ghost_position():
	if move_input.length() > 0:
		ghost_position.x += move_input.x * grid_size
		ghost_position.z += move_input.y * grid_size
	
	# Snap to grid
	ghost_position.x = snapped(ghost_position.x, grid_size)
	ghost_position.z = snapped(ghost_position.z, grid_size)
	ghost_building.global_transform.origin = ghost_position

func _update_ghost_rotation():
	is_rotating = true

	
func place_building():
	if not selected_building_scene or not ghost_building:
		return

	var placed_building = selected_building_scene.instantiate()
	placed_building.global_transform.origin = ghost_building.global_transform.origin
	placed_building.rotation_degrees.y = rotation_angle  # Apply final rotation

	add_child(placed_building)

	ghost_building.queue_free()
	ghost_building = null
	is_placing_building = false  

	move_timer.stop()  # Stop updating movement
	player.set_physics_process(true)
	camera_pivot.set_process(true)

func cancel_building():
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null

	is_placing_building = false
	move_timer.stop()  
	player.set_physics_process(true)
	camera_pivot.set_process(true)
