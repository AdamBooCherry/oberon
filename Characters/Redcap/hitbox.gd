extends Area3D
class_name Hitbox

@export var damage: float = 10.0

signal hit_registered(target: Node3D)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	# Ignore standard hitboxes to prevent self-hitting
	if area is not Hitbox:
		return
		
	# Check if the collided area (e.g., Hurtbox) or its root entity handles damage
	if area.has_method("take_damage"):
		area.take_damage(damage)
		hit_registered.emit(area)
	elif area.owner and area.owner.has_method("take_damage"):
		area.owner.take_damage(damage)
		hit_registered.emit(area.owner)

func enable() -> void:
	monitoring = true

func disable() -> void:
	monitoring = false
