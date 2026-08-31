extends Node3D
class_name FrogSpawner

@export var spawn_markers: Array[FrogSpawnMarker] = []
@export var frog_scene: PackedScene = preload("uid://cdffe7bphgot8")

var _active_frog: Node3D = null

func _ready() -> void:
	if GameManager.has_signal("day_number_changed"):
		GameManager.day_number_changed.connect(_on_day_changed)
	
	spawn_random_frog()

func _on_day_changed(_day_value: int) -> void:
	spawn_random_frog()

func spawn_random_frog() -> void:
	if spawn_markers.is_empty() or not frog_scene:
		return

	# Despawn previous day's uncollected frog
	if is_instance_valid(_active_frog):
		_active_frog.queue_free()

	# Select a random marker and instantiate
	var selected_marker: FrogSpawnMarker = spawn_markers.pick_random()
	if not is_instance_valid(selected_marker):
		return

	_spawn_frog_at(selected_marker.global_transform)

func _spawn_frog_at(target_transform: Transform3D) -> void:
	var new_frog = frog_scene.instantiate() as Node3D
	if not new_frog:
		return

	# Add to tree first, then set global transform
	add_child(new_frog)
	new_frog.global_transform = target_transform

	_active_frog = new_frog
