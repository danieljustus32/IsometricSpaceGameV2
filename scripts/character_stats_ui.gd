extends Control

@onready var health_bar: TextureProgressBar = $TextureProgressBar

func _ready():
	# Check if health_bar is valid before trying to access it
	var world_node = get_tree().root.get_node("World")
	var world_children = world_node.get_children()

	# Print all the children of the World node
	print("Children of World:", world_children)	
	get_viewport().size_changed.connect(update_position)
	update_position()
	SignalBus.health_updated.connect(update_health)

func update_position():
	# Ensure that the health bar is valid and positioned correctly
	if health_bar:
		print("Updating health bar position")
		
		# Get the size of the health bar
		var health_bar_width = health_bar.get_rect().size.x
		var health_bar_height = health_bar.get_rect().size.y
		
		# Get the viewport size
		var viewport_size = get_viewport().size
		
		# Position at the bottom-center of the screen
		health_bar.position.x = (viewport_size.x - health_bar_width) / 2
		health_bar.position.y = viewport_size.y - health_bar_height - 25  # 25px margin from the bottom

		

func update_health(value: int):
	if health_bar:
		health_bar.value = value
