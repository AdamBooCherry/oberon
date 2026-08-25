extends Node3D
class_name RevealPinata

@export var reveal_health: float = 10.0
@export var candy_range: Vector2 = Vector2(5, 15)

@export_group("References")
@export var reveal_detector: RevealDetector
@export var candy_scene: PackedScene

var is_breaking: bool = false

const BREAK_EFFECT = preload("uid://dqo2wy1r43ocf")

func _process(delta: float) -> void:
	if is_breaking:
		return
		
	if reveal_detector.current_reveal_area == null:
		return
	
	var distance = _calculate_distance()
	
	var damage_rate = 5.0
	reveal_health -= damage_rate * delta
	
	if reveal_health <= 0.0:
		_break_pinata()

func _calculate_distance() -> float:
	var pinata_pos = global_position
	var area_pos = reveal_detector.current_reveal_area.global_position
	return pinata_pos.distance_to(area_pos)

func _break_pinata() -> void:
	if is_breaking:
		return
	is_breaking = true
	
	print("[PinataDebug] Breaking pinata at position: ", global_position)
	
	# [SOUND HOOK] Play pinata shatter / explosion sound here
	SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", self.global_position, get_parent())
	
	if candy_scene:
		# Extract min (x) and max (y) from our Vector2, cast to int for randi_range
		var min_c = int(candy_range.x)
		var max_c = int(candy_range.y)
		var candy_count = randi_range(min_c, max_c)
		
		print("[PinataDebug] Spawning ", candy_count, " candies...")
		
		for i in range(candy_count):
			var candy = candy_scene.instantiate() as Node3D
			if not candy:
				print("[PinataDebug] ERROR: Failed to instantiate candy scene at index ", i)
				continue
				
			get_parent().add_child(candy)
			candy.global_position = global_position
			
			# Full 360-degree spread with tight close-range distance (1.0 to 2.0 meters)
			var random_angle = randf_range(0.0, TAU)
			var random_distance = randf_range(1.0, 2.0) 
			var landing_offset = Vector3(cos(random_angle) * random_distance, 0.0, sin(random_angle) * random_distance)
			var target_position = global_position + landing_offset
			
			# Quick flight duration for close arcs
			var duration = randf_range(0.5, 1.0)
			_animate_candy_arc(candy, global_position, target_position, duration, i)

	# Delay queue_free so the pinata node stays alive until the candy arcs finish landing
	hide()
	var cleanup_tween = create_tween()
	cleanup_tween.tween_interval(2.0)
	cleanup_tween.tween_callback(queue_free)

func _animate_candy_arc(candy: Node3D, start_pos: Vector3, end_pos: Vector3, duration: float, index: int) -> void:
	if not candy:
		return
		
	var tween = create_tween().set_parallel(true)
	
	# Low arc height for close-range popping (1.0 to 2.0 meters high)
	var arc_height = randf_range(1.0, 2.0)
	
	tween.tween_method(
		func(t: float):
			if not is_instance_valid(candy):
				return
			var current_pos = start_pos.lerp(end_pos, t)
			current_pos.y += sin(t * PI) * arc_height
			candy.global_position = current_pos,
		0.0, 1.0, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(candy, "rotation:y", candy.rotation.y + randf_range(6.28, 25.12), duration)
	
	tween.chain().tween_callback(func():
		# [SOUND HOOK] Play individual candy land sound here
		pass
	)
