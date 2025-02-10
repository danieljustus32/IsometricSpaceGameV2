extends Node

@export var max_health: int = 100
var current_health: int

signal health_changed(new_health)
signal died

func _ready():
	current_health = 75
	emit_signal("health_changed", current_health)  # Notify UI at start

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health)

	if current_health == 0:
		die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed", current_health)

func die():
	emit_signal("died")
	print("Character has died!")  # Replace with actual death logic
