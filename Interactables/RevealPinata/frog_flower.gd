extends Node3D
class_name FrogFlower

@export var rotation_speed: float = 0.2

@export_group("Awakening Growth")
@export var sleeping_scale: Vector3 = Vector3(0.5, 0.5, 1.0)
@export var grow_duration: float = 3.0
@export var grow_curve: Curve

@export_group("References")
@export var reveal_pinata: RevealPinata
@export var head_marker: Marker3D
@export var beam_transform: Node3D

var all_frogs: Array[Node] = []
var _closest_frog: FrogMob = null
var is_awake: bool = false
var _grow_tween: Tween = null

const BREAK_EFFECT = preload("uid://dqo2wy1r43ocf")

func _ready() -> void:
	if GameManager.has_signal("day_number_changed"):
		GameManager.day_number_changed.connect(_on_day_number_changed)

	if reveal_pinata:
		reveal_pinata.pinata_broken.connect(_awaken_flower)

	_sleep_flower()

func find_frogs() -> void:
	all_frogs = get_tree().get_nodes_in_group("FROG")

func _process(delta: float) -> void:
	if not is_awake:
		return

	_update_closest_frog()

	# If no valid targets remain, fall back asleep
	if not _closest_frog or not is_instance_valid(_closest_frog):
		_sleep_flower()
		return

	var current_transform = head_marker.global_transform
	var target_transform = current_transform.looking_at(_closest_frog.global_position, Vector3.UP)

	var current_quat = current_transform.basis.get_rotation_quaternion()
	var target_quat = target_transform.basis.get_rotation_quaternion()

	var smoothed_quat = current_quat.slerp(target_quat, rotation_speed * delta)
	head_marker.global_transform = Transform3D(Basis(smoothed_quat), current_transform.origin)

func _awaken_flower() -> void:
	if is_awake:
		return

	# Don't awaken if there are no targets in the world
	find_frogs()
	if all_frogs.is_empty():
		return

	is_awake = true
	SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", self.global_position, get_parent())

	if _grow_tween and _grow_tween.is_running():
		_grow_tween.kill()

	_grow_tween = create_tween()

	if head_marker:
		_grow_tween.tween_method(
			func(val: float):
				var factor = grow_curve.sample(val) if grow_curve else val
				head_marker.scale = sleeping_scale.lerp(Vector3.ONE, factor),
			0.0,
			1.0,
			grow_duration
		)

	if beam_transform:
		var orig_scale = beam_transform.scale
		var target_y = orig_scale.y if orig_scale.y > 0.01 else 1.0

		_grow_tween.parallel().tween_method(
			func(val: float):
				var factor = grow_curve.sample(val) if grow_curve else val
				var current_y = lerp(0.01, target_y, factor)
				beam_transform.scale = Vector3(orig_scale.x, current_y, orig_scale.z),
			0.0,
			1.0,
			grow_duration
		)

func _sleep_flower() -> void:
	is_awake = false
	_closest_frog = null

	if _grow_tween and _grow_tween.is_running():
		_grow_tween.kill()

	# Reset Pinata lifecycle state so it can be broken again
	if reveal_pinata:
		reveal_pinata.reset_pinata()

	# Shrink visuals smoothly back to sleeping state
	_grow_tween = create_tween()

	if head_marker:
		_grow_tween.tween_property(head_marker, "scale", sleeping_scale, 0.5)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	if beam_transform:
		var current_scale = beam_transform.scale
		_grow_tween.parallel().tween_property(beam_transform, "scale", Vector3(current_scale.x, 0.01, current_scale.z), 0.5)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	find_frogs()

func _update_closest_frog() -> void:
	if all_frogs.is_empty():
		find_frogs()
		if all_frogs.is_empty():
			_closest_frog = null
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

func _on_day_number_changed(_value: int) -> void:
	_sleep_flower()
