class_name PostureNeutralState
extends State

@export var glory_hand: GloryHand

func update(_delta: float) -> void:
	glory_hand.switch_pose(0.0)
	player.current_posture = 0.0
	
	# Don't allow entering lowered/raised states if the player is currently sprinting
	if Input.is_action_pressed("sprint"):
		return

	# Use "just_pressed" or check that the button wasn't held over from a sprint break
	if Input.is_action_just_pressed("raise_hog"):
		parent_state_machine.change_state("PostureRaisedState")
	elif Input.is_action_just_pressed("lower_hog"):
		parent_state_machine.change_state("PostureLoweredState")
