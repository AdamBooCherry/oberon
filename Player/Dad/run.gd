class_name RunState
extends State

func physics_update(delta: float) -> void:
	player.handle_turn(delta)
	
	var move_input := Input.get_axis("back", "forward")
	
	if move_input == 0.0:
		parent_state_machine.change_state("IdleState")
		return
		
	if move_input < 0 or not Input.is_action_pressed("sprint"):
		parent_state_machine.change_state("WalkState")
		return

	# 1. Apply Run Speed (forward only)
	var speed = player.run_speed
	var direction = player.transform.basis.z * move_input
	
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed

	# 2. Running forces action state to neutral posture
	if player.action_state_machine:
		player.action_state_machine.change_state("PostureNeutralState")

	# 3. Smoothly update Animation Blend for running (X = 1.0, Y = 0.5)
	player.update_animation_blend(1.0, 0.5, delta)
