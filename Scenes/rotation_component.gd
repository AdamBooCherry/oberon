class_name RotationComponent
extends Node3D

@export var speed: float = 2.0
@export var x_axis: bool = false
@export var y_axis: bool = true   # Default to spinning on Y for convenience
@export var z_axis: bool = false

func _process(delta: float) -> void:
	var rotation_vector = Vector3.ZERO
	
	if x_axis:
		rotation_vector.x += 1.0
	if y_axis:
		rotation_vector.y += 1.0
	if z_axis:
		rotation_vector.z += 1.0
		
	if rotation_vector != Vector3.ZERO:
		# Rotate relative to the parent object's local space
		rotate(rotation_vector.normalized(), speed * delta)
