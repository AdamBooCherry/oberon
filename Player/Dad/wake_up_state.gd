### DAD WAKEUP ###
extends State

@export var player_dad: Player
@export var control_delay: float = 0.0

func enter() -> void:
	print("STATE: DadWakeupState -> enter()")
	player_dad.velocity = Vector3.ZERO
	player_dad.disable_action_control()
	
	# 1. Fire the OneShot node inside the AnimationTree
	var anim_node = player_dad.movement_tree.tree_root.get_node("OneShotAnimation")
	anim_node.animation = "Dad/stand_up"
	player_dad.movement_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	# 2. Wait until the OneShot is finished playing
	# (Since animation_finished won't fire from AnimationPlayer directly)
	while player_dad.movement_tree.get("parameters/OneShot/active"):
		await player_dad.get_tree().process_frame
	
	if control_delay > 0.0:
		print("STATE: DadWakeupState -> Waiting control delay (", control_delay, "s)...")
		await player_dad.get_tree().create_timer(control_delay).timeout
		
	if player_dad.hurtbox:
		player_dad.hurtbox.set_deferred("monitoring", true)
		player_dad.hurtbox.set_deferred("monitorable", true)

	player_dad.enable_action_control()
	player_dad.movement_state_machine.change_state("IdleState")
