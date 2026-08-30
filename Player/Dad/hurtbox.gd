extends Area3D
class_name Hurtbox

signal damage_received(amount: float, attacker: Node3D)

@export var health_component: HealthComponent
@export var is_invulnerable: bool = false


func take_damage(amount: float, attacker: Node3D = null) -> void:
	print("taking damage")
	if is_invulnerable:
		return

	damage_received.emit(amount, attacker)

	# Relay directly to the assigned HealthComponent
	if health_component:
		health_component.take_damage(amount)
	# Fallback if unassigned in inspector: check root entity
	elif owner and owner.has_method("take_damage"):
		owner.take_damage(amount)
