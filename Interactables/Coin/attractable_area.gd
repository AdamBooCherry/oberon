extends Area3D
class_name AttractableArea

signal collected(collector: AttractionArea)

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
	# Disable collisions immediately to prevent double collection
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	if current_attractor:
		current_attractor.notify_collected(get_parent())

	collected.emit(current_attractor)
	
	# Clean up parent actor (Coin, SilverFrog, etc.)
	var parent := get_parent()
	if is_instance_valid(parent) and parent != get_tree().root:
		parent.queue_free()
	else:
		queue_free()
