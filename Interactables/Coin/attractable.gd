extends Node
class_name Attractable

signal collected(collector: AttractionArea)

@export var area_3d: Area3D
@export var homing_component: HomingComponent

var is_collected: bool = false
var current_attractor: AttractionArea = null

func _ready() -> void:
	if homing_component:
		homing_component.arrived.connect(_on_homing_arrived)

func start_attraction(attractor: AttractionArea) -> void:
	if is_collected:
		return

	is_collected = true
	current_attractor = attractor

	if homing_component:
		homing_component.start_homing(attractor)

func stop_attraction(attractor: AttractionArea) -> void:
	if current_attractor == attractor and not is_collected:
		current_attractor = null
		if homing_component:
			homing_component.stop_homing()

func _on_homing_arrived(target: Node3D) -> void:
	if area_3d:
		area_3d.set_deferred("monitoring", false)
		area_3d.set_deferred("monitorable", false)

	if current_attractor:
		current_attractor.notify_collected(get_parent())

	collected.emit(current_attractor)
	_on_pickup_complete()

func _on_pickup_complete() -> void:
	# Virtual method meant to be overridden or handled by owner
	get_parent().queue_free()
