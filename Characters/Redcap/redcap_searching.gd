## REDCAP SEARCHING ##
extends State

@export var redcap: Redcap
@export var search_duration: float = 5.0
@export var turn_speed: float = 2.0
@export var rotation_speed: float = 8.0

var _timer: float = 0.0
var _has_reached_destination: bool = false

func enter() -> void:
	_timer = 0.0
	_has_reached_destination = false

	if not redcap:
		return

	# Play search movement animation
	if redcap.animation_player:
		#if redcap.animation_player.has_animation("drunk_walk_backwards"):
			#redcap.animation_player.play("drunk_walk_backwards")
		#elif redcap.animation_player.has_animation("redcap_animations/drunk_walk_backwards"):
			#redcap.animation_player.play("redcap_animations/drunk_walk_backwards")
		redcap.animation_player.play("redcap_animations/drunk_walk_backwards")

	# Set pathfinding target to the last reported position
	if redcap.navigation_agent_3d:
		if redcap.last_known_player_position != Vector3.ZERO:
			redcap.navigation_agent_3d.target_position = redcap.last_known_player_position
		else:
			# Fallback: if no last position recorded, search near current spot
			redcap.navigation_agent_3d.target_position = redcap.global_position

func physics_update(delta: float) -> void:
	if not redcap or not redcap.navigation_agent_3d:
		return

	var nav_agent = redcap.navigation_agent_3d

	# Phase 1: Move along the navigation path to target position
	if not nav_agent.is_navigation_finished():
		var current_pos = redcap.global_position
		var next_path_pos = nav_agent.get_next_path_position()
		var dir = (next_path_pos - current_pos).normalized()
		dir.y = 0 # Keep movement horizontal

		redcap.velocity = dir * redcap.move_speed

		# Smoothly turn Redcap toward velocity direction
		if dir.length_squared() > 0.01:
			var target_rotation = atan2(-dir.x, -dir.z)
			redcap.rotation.y = lerp_angle(redcap.rotation.y, target_rotation, rotation_speed * delta)

	# Phase 2: Arrived at point — stop and sweep back-and-forth
	else:
		if not _has_reached_destination:
			_has_reached_destination = true
			redcap.velocity = Vector3.ZERO

			# Switch to idle look-around animation if available
			if redcap.animation_player:
				if redcap.animation_player.has_animation("drunk_idle_01"):
					redcap.animation_player.play("drunk_idle_01")
				elif redcap.animation_player.has_animation("redcap_animations/drunk_idle_01"):
					redcap.animation_player.play("redcap_animations/drunk_idle_01")

		_timer += delta
		redcap.rotate_y(sin(_timer * turn_speed) * 0.02)

		if _timer >= search_duration:
			if parent_state_machine:
				parent_state_machine.change_state("IDLE")
