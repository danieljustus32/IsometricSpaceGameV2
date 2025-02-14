extends Node3D

@export var grid_size: float = 1.0  # Grid-based placement (1m x 1m)
@export var placement_offset: float = 10.0  # Distance in front of player
@onready var player: CharacterBody3D = StateMachine.player

var selected_building_scene: PackedScene
var ghost_building: Node3D  # Temporary preview before placement
var is_placing_building = false  # Tracks if a building is being placed

func _ready():
	# Listen for when a building is selected from the menu
	SignalBus.building_selected.connect(_on_building_selected)

func _on_building_selected(building_scene: PackedScene):
	if is_placing_building:
		return  # Prevent selecting a new building while placing

	is_placing_building = true

	# Deselect any focused UI element to prevent button selection issues
	get_viewport().gui_release_focus()

	# Remove existing ghost building if present
	if ghost_building:
		ghost_building.queue_free()

	selected_building_scene = building_scene
	ghost_building = selected_building_scene.instantiate()
	ghost_building.set_collision_layer_value(1, false)  # Disable collisions during preview

	add_child(ghost_building)
	_update_ghost_position()


func _process(delta):
	if ghost_building:
		_update_ghost_position()
		if Input.is_action_just_pressed("confirm_building"):
			place_building()

func _update_ghost_position():
	if not player or not ghost_building:
		return
	
	# Get the position in front of the player
	var forward_dir = player.global_transform.basis.z
	var target_pos = player.global_transform.origin + forward_dir * placement_offset
	
	# Snap position to grid
	target_pos.x = snapped(target_pos.x, grid_size)
	target_pos.z = snapped(target_pos.z, grid_size)
	target_pos.y = 0.5  # Keep buildings slightly off the ground

	ghost_building.global_transform.origin = target_pos

func place_building():
	if not selected_building_scene or not ghost_building:
		return

	# Finalize placement
	var placed_building = selected_building_scene.instantiate()
	placed_building.global_transform.origin = ghost_building.global_transform.origin
	add_child(placed_building)

	# Cleanup
	ghost_building.queue_free()
	ghost_building = null
	is_placing_building = false  # Reset flag
