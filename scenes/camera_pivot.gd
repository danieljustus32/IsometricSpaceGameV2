extends Node3D

@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("PlayerCharacter")[0]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = player.global_position
