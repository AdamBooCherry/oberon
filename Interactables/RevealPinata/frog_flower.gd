#@icon("res://addons/at-icons/node3d/flower.svg")
extends Node3D
class_name FrogFlower

#@export var reveal_health: float = 10.0
@export var rotation_speed: float = 0.2 # Higher = faster turn rate, Lower = slower/lazier tracking

@export_group("Awakening Growth")
@export var sleeping_scale: Vector3 = Vector3(0.5, 0.5, 1.0)
@export var grow_duration: float = 3.0
@export var grow_curve: Curve

@export_group("References")
@export var reveal_detector: RevealDetector
@export var head_marker: Marker3D
@export var beam_transform: Node3D

var all_frogs: Array[Node] 
var _closest_frog: FrogMob

var is_awake: bool = false

const BREAK_EFFECT = preload("uid://dqo2wy1r43ocf")

func _ready() -> void:
	find_frogs()
	
	# Set initial sleeping scale if head_marker exists
	if head_marker:
		head_marker.scale = sleeping_scale
		
	# Set initial beam Y scale to nearly 0 while sleeping
	if beam_transform:
		var current_scale = beam_transform.scale
		beam_transform.scale = Vector3(current_scale.x, 0.01, current_scale.z)

func find_frogs() -> void:
	all_frogs = get_tree().get_nodes_in_group("FROG")

func _process(delta: float) -> void:
	# 1. Handle health depletion while sleeping using the updated detector API
	if not is_awake:
		if reveal_detector and reveal_detector.is_in_light():
			# Multiplies damage rate by how many reveal sources hit the flower
			var damage_rate = 5.0 * reveal_detector.active_reveal_areas.size()
			reveal_detector.health_component.take_damage(damage_rate * delta)
			#reveal_detector.health_component.current_health -= damage_rate * delta
			
			if reveal_detector.health_component.current_health <= 0.0:
				_awaken_flower()
		return
	
	# 2. Once awake, continuously find and track the nearest frog
	_update_closest_frog()
	
	if _closest_frog and is_instance_valid(_closest_frog):
		# 1. Store the current global transform
		var current_transform = head_marker.global_transform
		
		# 2. Get the target transform by looking at the frog
		var target_transform = current_transform.looking_at(_closest_frog.global_position, Vector3.UP)
		
		# 3. Extract safe, normalized quaternions from both bases
		var current_quat = current_transform.basis.get_rotation_quaternion()
		var target_quat = target_transform.basis.get_rotation_quaternion()
		
		# 4. Slerp between the quaternions smoothly
		var smoothed_quat = current_quat.slerp(target_quat, rotation_speed * delta)
		
		# 5. Apply back to the marker, keeping position and scale intact
		var new_basis = Basis(smoothed_quat)
		head_marker.global_transform = Transform3D(new_basis, current_transform.origin)

func _awaken_flower() -> void:
	if is_awake:
		return
	is_awake = true
	
	print("[FrogFlowerDebug] Flower awakened!")
	
	SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", self.global_position, get_parent())
	
	# Grow the head marker and beam transform over three seconds using a tween
	var tween = create_tween()
	
	if head_marker:
		tween.tween_method(
			func(val: float):
				var factor = grow_curve.sample(val) if grow_curve else val
				head_marker.scale = sleeping_scale.lerp(Vector3.ONE, factor),
			0.0,
			1.0,
			grow_duration
		)
		
	if beam_transform:
		# Grab original x and z scales so we don't accidentally flatten them
		var orig_scale = beam_transform.scale
		var target_y = orig_scale.y if orig_scale.y > 0.01 else 1.0
		
		tween.parallel().tween_method(
			func(val: float):
				var factor = grow_curve.sample(val) if grow_curve else val
				var current_y = lerp(0.01, target_y, factor)
				beam_transform.scale = Vector3(orig_scale.x, current_y, orig_scale.z),
			0.0,
			1.0,
			grow_duration
		)

func _update_closest_frog() -> void:
	if all_frogs.is_empty():
		find_frogs()
		if all_frogs.is_empty():
			return
			
	var closest_dist: float = INF
	var nearest: FrogMob = null
	
	for frog in all_frogs:
		if not is_instance_valid(frog) or not (frog is FrogMob):
			continue
			
		var dist = global_position.distance_to(frog.global_position)
		if dist < closest_dist:
			closest_dist = dist
			nearest = frog
			
	_closest_frog = nearest
