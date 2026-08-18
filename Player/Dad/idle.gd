class_name IdleState
extends State

func physics_update(delta: float) -> void:
	# 1. Handle tank control turning while idle (allows turning in place)
	player.handle_turn(delta)

	# 2. Damp velocity to zero
	player.velocity.x = move_toward(player.velocity.x, 0, player.move_speed)
	player.velocity.z = move_toward(player.velocity.z, 0, player.move_speed)

	var move_input := Input.get_axis("back", "forward")
	var turn_input := Input.get_axis("turn_right", "turn_left")
	
	# 3. Handle transitions to Walk or Run if moving
	if move_input != 0.0:
		if Input.is_action_pressed("sprint") and move_input > 0:
			parent_state_machine.change_state("RunState")
		else:
			parent_state_machine.change_state("WalkState")
		return

	# 4. Determine X blend: 0.25 if turning in place, 0.0 if completely stationary
	var x_blend = 0.25 if abs(turn_input) > 0.0 else 0.0
	var y_blend = player.current_posture

	# Smoothly blend to idle or turn-in-place animation
	player.update_animation_blend(x_blend, y_blend, delta)
