class_name PostureLoweredState
extends State

func update(_delta: float) -> void:
	player.current_posture = -1.0
	
	var move_input := Input.get_axis("back", "forward")
	var is_running = Input.is_action_pressed("sprint") and move_input != 0.0
	
	# Return to neutral if:
	# 1. Player starts sprinting
	# 2. Player releases the lower button
	#print("[ActionState] PostureLowered active -> current_posture set to: ", player.current_posture)
	if is_running or not Input.is_action_pressed("lower_hog"):
		parent_state_machine.change_state("PostureNeutralState")
