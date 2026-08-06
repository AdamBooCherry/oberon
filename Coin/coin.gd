extends Node3D
class_name Coin

@export var area_3d: Area3D
@export var coin_value: int = 1

@export_category("Flight Settings")
@export var max_speed: float = 25.0
@export var speed_curve: Curve
@export var min_pickup_distance: float = 0.2

@export_group("References")
@export var pickup: AudioStreamPlayer3D

var _is_collected: bool = false
var _target_node: Node3D = null
var _start_distance: float = 0.0
var target_coin_collector: CoinCollector

func _ready() -> void:
	if area_3d:
		area_3d.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if _is_collected and is_instance_valid(_target_node):
		_fly_towards_target(delta)

func _on_area_entered(area: Area3D) -> void:
	if _is_collected:
		return
	
	if area is CoinCollector:
		target_coin_collector = area
		_is_collected = true
		_target_node = area
		
		# Record initial distance
		_start_distance = global_position.distance_to(_target_node.global_position)
		if _start_distance == 0.0:
			_start_distance = 0.001
		
		# Disable collisions immediately
		area_3d.set_deferred("monitoring", false)
		area_3d.set_deferred("monitorable", false)
		
		# Play the sound when collection triggers
		if pickup:
			pickup.play()

func _fly_towards_target(delta: float) -> void:
	var target_pos: Vector3 = _target_node.global_position
	var current_distance: float = global_position.distance_to(target_pos)
	
	# Check if reached destination
	if current_distance <= min_pickup_distance:
		InventoryManager.increment_currency(coin_value)
		
		target_coin_collector.on_pickup()
		queue_free()
		return

	# Calculate progress ratio
	var progress: float = clampf(1.0 - (current_distance / _start_distance), 0.0, 1.0)
	
	# Evaluate curve multiplier
	var speed_multiplier: float = 1.0
	if speed_curve:
		speed_multiplier = speed_curve.sample(progress)
	
	var current_speed: float = max_speed * speed_multiplier
	global_position = global_position.move_toward(target_pos, current_speed * delta)
	
	# Optional scale polish
	if current_distance < 2.0:
		scale = Vector3.ONE * (current_distance / 2.0)
