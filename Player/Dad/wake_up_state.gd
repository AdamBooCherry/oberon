### DAD WAKEUP ###
extends State

@export var player_dad: Player
@export var control_delay: float = 0.0

func enter() -> void:
	print("STATE: DadWakeupState -> enter()")
	player_dad.velocity = Vector3.ZERO
	player_dad.disable_action_control()
	
	print("STATE: DadWakeupState -> Playing stand_up animation...")
	player_dad.animation_player.play("Dad/stand_up")
	await player_dad.animation_player.animation_finished
	print("STATE: DadWakeupState -> stand_up animation finished.")
	
	if control_delay > 0.0:
		print("STATE: DadWakeupState -> Waiting control delay (", control_delay, "s)...")
		await player_dad.get_tree().create_timer(control_delay).timeout
		
	print("STATE: DadWakeupState -> Re-enabling hurtbox and controls.")
	if player_dad.hurtbox:
		player_dad.hurtbox.set_deferred("monitoring", true)
		player_dad.hurtbox.set_deferred("monitorable", true)

	player_dad.enable_action_control()
	player_dad.movement_state_machine.change_state("IdleState")

func exit() -> void:
	print("STATE: DadWakeupState -> exit()")
