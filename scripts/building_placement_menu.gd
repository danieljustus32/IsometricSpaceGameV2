extends Panel

@onready var button_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer
@onready var building_placement_manager: Node3D = $BuildingPlacementManager

var tween: Tween

@export var building_scenes: Array[PackedScene]  # Assign building scenes in the Inspector

var is_visible = false  # Tracks if menu is shown

func _ready():
	# Ensure the panel starts off-screen
	size = Vector2(get_viewport().size.x, get_viewport().size.y * 2 / 3)
	position.y = get_viewport().size.y  # Off-screen at start

	# Set margins
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)

	# Ensure buttons are displayed in a grid with 4 columns
	button_container.columns = 4

	populate_buttons()

func populate_buttons():
	# Clear existing buttons
	for child in button_container.get_children():
		child.queue_free()

	# Create buttons dynamically from building scenes
	for scene in building_scenes:
		var button = Button.new()
		var scene_name = scene.resource_path.get_file().get_basename()
		button.text = scene_name.capitalize()
		button.pressed.connect(_on_building_selected.bind(scene))
		button_container.add_child(button)

func _process(delta):
	if Input.is_action_just_pressed("open_building_menu") and not building_placement_manager.is_placing_building:
		toggle_menu()

func toggle_menu():
	is_visible = !is_visible
	var target_y = get_viewport().size.y * (1 - 2.0 / 3.0) if is_visible else get_viewport().size.y

	# Animate movement
	tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", target_y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_building_selected(building_scene: PackedScene):
	print("Selected building: ", building_scene.resource_path.get_file().get_basename())
	toggle_menu()
	start_building_placement(building_scene)

func start_building_placement(building_scene: PackedScene):
	print("Starting placement for: ", building_scene.resource_path.get_file().get_basename())
	SignalBus.building_selected.emit(building_scene)  # Emit a signal to handle spawning elsewhere
