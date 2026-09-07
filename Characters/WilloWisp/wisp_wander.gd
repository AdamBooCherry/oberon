class_name WispWanderState
extends State

@export var wisp: WilloWisp
@export var move_speed: float = 3.0
@export var wander_radius: float = 8.0

func enter() -> void:
	if not is_instance_valid(wisp):
		return
	_pick_new_wander_target()

func physics_update(_delta: float) -> void:
	if not is_instance_valid(wisp) or not wisp.navigation_agent_3d:
		return

	if wisp.navigation_agent_3d.is_navigation_finished():
		wisp.state_machine.change_state("WispIdle")
		return

	var current_pos: Vector3 = wisp.global_position
	var next_pos: Vector3 = wisp.navigation_agent_3d.get_next_path_position()
	
	var dir: Vector3 = (next_pos - current_pos)
	dir.y = 0.0 # Restrict movement to ground plane

	if dir.length_squared() > 0.001:
		wisp.velocity = dir.normalized() * move_speed
		wisp.move_and_slide()

func exit() -> void:
	if is_instance_valid(wisp):
		wisp.velocity = Vector3.ZERO

func _pick_new_wander_target() -> void:
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)
	var random_target: Vector3 = wisp.global_position + random_offset
	var map := wisp.get_world_3d().navigation_map
	
	wisp.navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(map, random_target)
