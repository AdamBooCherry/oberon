extends State
class_name StateActionNeutral

func enter() -> void:
	if player.animation_player:
		player.animation_player.play("idle", player.default_blend_time)
		player.animation_player.speed_scale = 1.0

func physics_update(delta: float) -> void:
	player.handle_turn(delta)
	
	# Smoothly decelerate to zero
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.move_speed * delta * 10.0)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.move_speed * delta * 10.0)
	
	# Check for movement input to transition
	var move_input := Input.get_axis("forward", "back")
	if move_input != 0.0:
		if Input.is_action_pressed("sprint") and move_input < 0.0:
			parent_state_machine.change_state("Run")
		else:
			parent_state_machine.change_state("Walk")
