class_name SceneHelper
extends Object

## Instantiates a packed scene (via UID or path) and adds it to a parent node at a specific global position.
static func spawn_effect(scene_path_or_uid: String, spawn_position: Vector3, parent_node: Node) -> Node:
	var packed_scene = load(scene_path_or_uid) as PackedScene
	if not packed_scene:
		print("[SceneHelper] ERROR: Failed to load scene from: ", scene_path_or_uid)
		return null
		
	var instance = packed_scene.instantiate()
	parent_node.add_child(instance)
	
	if instance is Node3D:
		instance.global_position = spawn_position
		
	return instance
