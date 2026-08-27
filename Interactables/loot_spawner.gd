extends Node3D
class_name LootSpawner

@export var loot_range: Vector2 = Vector2(5, 15)
@export var loot_scene: PackedScene # Can be candy, coins, or even a mini enemy scene!

func spawn_loot(origin_position: Vector3) -> void:
	if not loot_scene:
		print("[LootSpawner] ERROR: No loot_scene assigned!")
		return
		
	var min_c = int(loot_range.x)
	var max_c = int(loot_range.y)
	var spawn_count = randi_range(min_c, max_c)
	
	print("[LootSpawner] Spawning ", spawn_count, " items...")
	var world_root = get_tree().current_scene
	
	for i in range(spawn_count):
		var item = loot_scene.instantiate() as Node3D
		if not is_instance_valid(item):
			continue
			
		world_root.add_child(item)
		item.global_position = origin_position
		
		# Full 360-degree spread
		var random_angle = randf_range(0.0, TAU)
		var random_distance = randf_range(1.0, 2.0) 
		var landing_offset = Vector3(cos(random_angle) * random_distance, 0.0, sin(random_angle) * random_distance)
		var target_position = origin_position + landing_offset
		
		var duration = randf_range(0.5, 1.0)
		_animate_loot_arc(item, origin_position, target_position, duration)

func _animate_loot_arc(item: Node3D, start_pos: Vector3, end_pos: Vector3, duration: float) -> void:
	if not is_instance_valid(item):
		return
		
	var tween = create_tween().set_parallel(true)
	var arc_height = randf_range(1.0, 2.0)
	
	tween.tween_method(
		func(t: float):
			if not is_instance_valid(item):
				return
			var current_pos = start_pos.lerp(end_pos, t)
			current_pos.y += sin(t * PI) * arc_height
			item.global_position = current_pos,
		0.0, 1.0, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(item, "rotation:y", item.rotation.y + randf_range(6.28, 25.12), duration)
	
	tween.chain().tween_callback(func():
		if not is_instance_valid(item):
			return
		# [SOUND HOOK] Play individual item land sound here
		pass
	)
