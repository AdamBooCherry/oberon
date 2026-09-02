class_name SceneHelper
extends Object

static func spawn_effect(scene_path_or_uid: String, spawn_position: Vector3, parent_node: Node, direction: Vector3 = Vector3.ZERO) -> Node:
	var packed_scene = load(scene_path_or_uid) as PackedScene
	if not packed_scene:
		print("[SceneHelper] ERROR: Failed to load scene from: ", scene_path_or_uid)
		return null
		
	var instance = packed_scene.instantiate()
	parent_node.add_child(instance)
	
	if instance is Node3D:
		instance.global_position = spawn_position
		if direction != Vector3.ZERO and instance.has_method("orient_towards"):
			instance.orient_towards(direction)
		elif direction != Vector3.ZERO:
			instance.look_at(spawn_position + direction.normalized(), Vector3.UP)
			
	return instance
