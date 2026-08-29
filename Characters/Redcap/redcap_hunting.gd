## REDCAP HUNTING ##
extends State

@export var redcap: Redcap
@export var attack_range: float = 1.8
@export var rotation_speed: float = 10.0

func enter() -> void:
	GameManager.emit_change_to_scary_environment()

	if not redcap:
		return

	if redcap.animation_player:
		if redcap.animation_player.has_animation("drunk_run"):
			redcap.animation_player.play("drunk_run")
		elif redcap.animation_player.has_animation("redcap_animations/drunk_run"):
			redcap.animation_player.play("redcap_animations/drunk_run")

func physics_update(delta: float) -> void:
	if not redcap or not redcap.navigation_agent_3d:
		return

	var nav_agent = redcap.navigation_agent_3d

	# Continuously update destination to player's live position
	if redcap.last_known_player_position != Vector3.ZERO:
		nav_agent.target_position = redcap.last_known_player_position

	var current_pos = redcap.global_position
	var distance_to_target = current_pos.distance_to(nav_agent.target_position)

	# 1. Attack Distance Check: Switch to ATTACKING state when close enough
	if distance_to_target <= attack_range:
		redcap.velocity = Vector3.ZERO
		if parent_state_machine:
			parent_state_machine.change_state("ATTACKING")
		return

	# 2. Movement & Navigation Pursuit
	if not nav_agent.is_navigation_finished():
		var next_path_pos = nav_agent.get_next_path_position()
		var dir = (next_path_pos - current_pos).normalized()
		dir.y = 0

		# Apply faster chase speed defined in Redcap settings
		redcap.velocity = dir * redcap.chase_speed

		# Smoothly rotate face direction toward velocity
		if dir.length_squared() > 0.01:
			var target_rotation = atan2(-dir.x, -dir.z)
			redcap.rotation.y = lerp_angle(redcap.rotation.y, target_rotation, rotation_speed * delta)
	else:
		# Target position reached without finding player -> switch to SEARCHING loop
		if parent_state_machine:
			parent_state_machine.change_state("WANDERING")
