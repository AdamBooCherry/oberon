extends Node3D
class_name RandomSpawner

@export var spawn_scene: PackedScene

var spawn_markers: Array[SpawnMarker] = []
var _active_instance: Node3D = null

func _ready() -> void:
	if GameManager.has_signal("day_number_changed"):
		GameManager.day_number_changed.connect(_on_day_changed)
	
	for child in get_children():
		if child is SpawnMarker:
			spawn_markers.append(child)
	
	spawn_random_subject()

func _on_day_changed(_day_value: int) -> void:
	spawn_random_subject()

func spawn_random_subject() -> void:
	if spawn_markers.is_empty() or not spawn_scene:
		return

	# Despawn previous day's uncollected instance
	if is_instance_valid(_active_instance):
		_active_instance.queue_free()

	# Select a random marker and instantiate
	var selected_marker: SpawnMarker = spawn_markers.pick_random()
	if not is_instance_valid(selected_marker):
		return

	_spawn_at(selected_marker.global_transform)

func _spawn_at(target_transform: Transform3D) -> void:
	var new_instance = spawn_scene.instantiate() as Node3D
	if not new_instance:
		return

	# Add to tree first, then set global transform
	add_child(new_instance)
	new_instance.global_transform = target_transform

	_active_instance = new_instance
