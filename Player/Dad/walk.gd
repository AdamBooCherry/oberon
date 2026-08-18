class_name WalkState
extends State

func physics_update(delta: float) -> void:
	player.handle_turn(delta)
	
	var move_input := Input.get_axis("back", "forward")
	
	# Sprinting forces return to neutral posture and transitions to RunState
	if Input.is_action_pressed("sprint") and move_input > 0.0:
		if player.action_state_machine:
			player.action_state_machine.change_state("PostureNeutralState")
		parent_state_machine.change_state("RunState")
		return

	if move_input == 0.0:
		parent_state_machine.change_state("IdleState")
		return

	# 1. Base speed selection (forward vs backward)
	var base_speed = player.backward_speed if move_input < 0 else player.move_speed
	
	# 2. Determine speed multiplier based on current posture
	var posture_multiplier = 1.0
	if player.current_posture < 0.5:
		# Lowered (0.0 to 0.5 range)
		var t = player.current_posture / 0.5 # 0.0 at fully lowered, 1.0 at neutral
		posture_multiplier = lerp(player.lowered_speed_multiplier, 1.0, t)
	elif player.current_posture > 0.5:
		# Raised (0.5 to 1.0 range)
		var t = (player.current_posture - 0.5) / 0.5 # 0.0 at neutral, 1.0 at fully raised
		posture_multiplier = lerp(1.0, player.raised_speed_multiplier, t)

	var final_speed = base_speed * posture_multiplier
	var direction = player.transform.basis.z * move_input
	
	player.velocity.x = direction.x * final_speed
	player.velocity.z = direction.z * final_speed

	# 3. Smoothly update Animation Blend
	var x_blend = move_input * 0.5 
	var y_blend = player.current_posture
	
	player.update_animation_blend(x_blend, y_blend, delta)
