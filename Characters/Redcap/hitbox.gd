extends Area3D
class_name Hitbox

@export var damage: float = 10.0

signal hit_registered(target: Node3D)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	# Ignore standard hitboxes to prevent self-hitting
	if area is Hurtbox:
		hurt_target(area)

func hurt_target(hurtbox: Hurtbox):
	print("hurt target!")
	hurtbox.take_damage(damage)
	hit_registered.emit(hurtbox.owner)
	pass

func enable() -> void:
	monitoring = true
	monitorable = false

func disable() -> void:
	monitoring = false
	monitorable = false
