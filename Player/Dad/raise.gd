class_name PostureLoweredState
extends State

@export var lower_light: SpotLight3D
@export var lower_color: Color = Color.CYAN
@export var tween_duration: float = 0.25 # How long the fade takes
@export var glory_hand: GloryHand

func enter() -> void:
	glory_hand.set_flame_color(lower_color)
	if not lower_light:
		return
		
	# Smoothly fade light energy up to 5.0
	var tween = create_tween()
	tween.tween_property(lower_light, "light_energy", 5.0, tween_duration)

func update(_delta: float) -> void:
	player.current_posture = -1.0
	
	# If sprinting, or if you let go of the lower button, switch back to neutral
	var is_sprinting = Input.is_action_pressed("sprint")
	
	if is_sprinting or not Input.is_action_pressed("lower_hog"):
		parent_state_machine.change_state("PostureNeutralState")

func exit() -> void:
	glory_hand.set_flame_color(glory_hand.default_flame_color)
	if not lower_light:
		return
		
	# Smoothly fade light energy back down to 0 when exiting
	var tween = create_tween()
	tween.tween_property(lower_light, "light_energy", 0.0, tween_duration)
