## REDCAP WANDERING ##
extends State

@export var redcap: Redcap
@export var wander_radius: float = 8.0
@export var pause_duration: float = 3.0
@export var turn_speed: float = 2.0
@export var rotation_speed: float = 8.0

var _timer: float = 0.0
var _has_reached_destination: bool = false

func enter() -> void:
	EnvironmentManager.change_state(EnvironmentManager.EnvironmentState.INVESTIGATING)
	
	_timer = 0.0
	_has_reached_destination = false

	if not redcap:
		return

	# Play walk animation
	if redcap.animation_player:
		if redcap.animation_player.has_animation("drunk_walk"):
			redcap.animation_player.play("drunk_walk")
		elif redcap.animation_player.has_animation("redcap_animations/drunk_walk"):
			redcap.animation_player.play("redcap_animations/drunk_walk")

	# Pick a random point on the navigation mesh near current position
	_pick_random_wander_target()

func physics_update(delta: float) -> void:
	if not redcap or not redcap.navigation_agent_3d:
		return

	var nav_agent = redcap.navigation_agent_3d

	# Phase 1: Walk to the random destination
	if not nav_agent.is_navigation_finished():
		var current_pos = redcap.global_position
		var next_path_pos = nav_agent.get_next_path_position()
		var dir = (next_path_pos - current_pos).normalized()
		dir.y = 0

		redcap.velocity = dir * redcap.move_speed

		if dir.length_squared() > 0.01:
			var target_rotation = atan2(-dir.x, -dir.z)
			redcap.rotation.y = lerp_angle(redcap.rotation.y, target_rotation, rotation_speed * delta)

	# Phase 2: Reached point — stop, look around, then transition
	else:
		if not _has_reached_destination:
			_has_reached_destination = true
			redcap.velocity = Vector3.ZERO

			if redcap.animation_player:
				if redcap.animation_player.has_animation("drunk_idle_01"):
					redcap.animation_player.play("drunk_idle_01")
				elif redcap.animation_player.has_animation("redcap_animations/drunk_idle_01"):
					redcap.animation_player.play("redcap_animations/drunk_idle_01")

		_timer += delta
		redcap.rotate_y(sin(_timer * turn_speed) * 0.02)

		if _timer >= pause_duration:
			if parent_state_machine:
				parent_state_machine.change_state("IDLE")

func _pick_random_wander_target() -> void:
	if not redcap or not redcap.navigation_agent_3d:
		return

	# Generate a random offset vector on the XZ plane
	var random_direction = Vector3(
		randf_range(-1.0, 1.0),
		0.0,
		randf_range(-1.0, 1.0)
	).normalized() * randf_range(wander_radius * 0.5, wander_radius)

	var origin = redcap.global_position + random_direction

	# Snaps the target point directly onto the valid NavigationMesh
	var random_point = NavigationServer3D.map_get_closest_point(
		redcap.get_world_3d().get_navigation_map(),
		origin
	)

	redcap.navigation_agent_3d.target_position = random_point
