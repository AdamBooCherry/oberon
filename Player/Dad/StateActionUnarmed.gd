class_name PostureNeutralState
extends State

func update(_delta: float) -> void:
	player.current_posture = 0.0
	#print("[ActionState] PostureNeutral active -> current_posture set to: ", player.current_posture)
	
	if Input.is_action_pressed("raise_hog"): # Or whatever your input action is named
		parent_state_machine.change_state("PostureRaisedState")
	elif Input.is_action_pressed("lower_hog"):
		parent_state_machine.change_state("PostureLoweredState")
