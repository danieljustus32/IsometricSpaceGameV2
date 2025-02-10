extends Area3D

@export var damage_per_second: int = 10
@export var tick_rate: float = 1.0  # Time between damage ticks

var characters_inside: Array[CharacterBody3D] = []
var _damage_timer: float = 0.0

func _process(delta):
	_damage_timer += delta
	if _damage_timer >= tick_rate:
		_damage_timer = 0.0
		apply_damage()

func apply_damage():
	print("Applying damage... Characters inside:", characters_inside.size())  # Debugging
	for character in characters_inside:
		if character.has_meta("player"):  # Ensure it's the player
			print("Damaging player...")
			var current_health = StateMachine.current_health
			var new_health = max(current_health - damage_per_second, 0)
			
			StateMachine.current_health = new_health  # Update state machine variable
			print(StateMachine.current_health)
			SignalBus.health_updated.emit(new_health)  # Notify UI and other systems

			if new_health <= 0:
				character.die()  # Call a death function (to be implemented)

func _on_body_entered(body):
	if body is CharacterBody3D and body not in characters_inside:
		characters_inside.append(body)
		print("Something entered HurtZone!")
	if body.is_in_group("Player"):
		print("Player entered HurtZone!")  # Debugging

func _on_body_exited(body):
	if body in characters_inside:
		characters_inside.erase(body)
		print(body.name, " exited HurtZone!")
	else:
		print(body.name, " tried to exit but wasn't tracked!")
