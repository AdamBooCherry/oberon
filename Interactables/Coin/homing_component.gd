class_name HomingComponent
extends Node

signal arrived(target: Node3D)
signal homing_lost

@export_category("Flight Settings")
@export var min_speed: float = 8.0
@export var max_speed: float = 25.0
@export var acceleration: float = 30.0
@export var speed_curve: Curve
@export var min_pickup_distance: float = 0.2

var _is_homing: bool = false
var _target_node: Node3D = null
var _start_distance: float = 0.0
var _current_speed: float = 0.0
var _actor: Node3D = null

func _ready() -> void:
	_actor = get_parent() as Node3D
	if not _actor:
		push_error("[HomingComponent] Parent must be a Node3D!")

func _process(delta: float) -> void:
	if _is_homing and is_instance_valid(_target_node) and is_instance_valid(_actor):
		_fly_towards_target(delta)

func stop_homing() -> void:
	if not _is_homing:
		return
		
	print("[HomingComponent] Homing stopped on: ", _actor.name if _actor else "null")
	_is_homing = false
	_target_node = null
	_current_speed = 0.0
	
	if is_instance_valid(_actor):
		_actor.scale = Vector3.ONE
		
	homing_lost.emit()

func start_homing(target: Node3D) -> void:
	if not is_instance_valid(target) or not _actor:
		print("[HomingComponent] ERROR: Cannot start homing. Target or Actor is invalid.")
		return

	_target_node = target
	_is_homing = true
	_current_speed = min_speed
	_start_distance = _actor.global_position.distance_to(_target_node.global_position)

	print("[HomingComponent] Started homing ", _actor.name, " -> ", _target_node.name, " (Dist: ", _start_distance, ")")

func _fly_towards_target(delta: float) -> void:
	var target_pos: Vector3 = _target_node.global_position
	var current_distance: float = _actor.global_position.distance_to(target_pos)

	# 1. Check if we arrived within pickup threshold
	if current_distance <= min_pickup_distance:
		print("[HomingComponent] Arrived! Reached distance: ", current_distance, " <= ", min_pickup_distance)
		_is_homing = false
		var final_target := _target_node
		_target_node = null
		arrived.emit(final_target)
		return

	# 2. Ramp speed up toward max_speed
	_current_speed = move_toward(_current_speed, max_speed, acceleration * delta)

	# 3. Move toward target
	_actor.global_position = _actor.global_position.move_toward(target_pos, _current_speed * delta)
