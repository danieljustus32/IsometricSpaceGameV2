extends Node3D

@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@onready var sky_camera: Camera3D = $SkyCamera
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StateMachine.camera_pivot = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Handle camera rotation
	if Input.is_action_pressed("rotate_camera_left"):
		rotation_degrees.y -= 1
		player.rotation_degrees.y -= 1
	if Input.is_action_pressed("rotate_camera_right"):
		rotation_degrees.y += 1
		player.rotation_degrees.y += 1
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		if sky_camera.size > 20:
			sky_camera.size -= 1
			
	if Input.is_action_just_pressed("zoom_out"):
		if sky_camera.size < 50:
			sky_camera.size += 1
			
