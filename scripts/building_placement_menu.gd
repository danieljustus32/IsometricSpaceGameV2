extends Panel

@onready var button_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var margin_container: MarginContainer = $MarginContainer
@onready var tween = get_tree().create_tween()

# Building types (editable list)
var building_types = ["Mining Station", "Farm", "Barracks", "Workshop"]

var is_visible = false  # Tracks if menu is shown

func _ready():
	# Ensure the panel starts off-screen
	size = Vector2(get_viewport().size.x, get_viewport().size.y * 2 / 3)
	position.y = get_viewport().size.y  # Off-screen at start
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	populate_buttons()

func populate_buttons():
	# Clear existing buttons
	for child in button_container.get_children():
		child.queue_free()

	# Create buttons dynamically
	for building in building_types:
		var button = Button.new()
		button.text = building
		button.pressed.connect(_on_building_selected.bind(building))
		button_container.add_child(button)

func _process(delta):
	if Input.is_action_just_pressed("place_building"):
		toggle_menu()

func toggle_menu():
	is_visible = !is_visible
	var target_y = get_viewport().size.y * (1 - 2.0 / 3.0) if is_visible else get_viewport().size.y

	# Animate movement
	tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", target_y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_building_selected(building_name):
	print("Selected building: ", building_name)
	toggle_menu()
	start_building_placement(building_name)

func start_building_placement(building_name):
	print("Starting placement for: ", building_name)
