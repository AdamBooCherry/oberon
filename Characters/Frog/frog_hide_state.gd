class_name FrogHideState
extends State

@export var frog: FrogMob
@export var hide_duration: float = 4.0

var _timer: float = 0.0

func enter() -> void:
	print("[HideState] ENTERED. Frog is hiding.")
	_timer = 0.0
	
	if frog:
		frog.velocity = Vector3.ZERO
		frog.set_hidden(true)

	if frog.animation_player:
		frog.animation_player.play("Armature|Frog_Idle")
		
		# Clear out navigation target so it doesn't try to keep moving or jitter
		if frog.navigation_agent_3d:
			frog.navigation_agent_3d.target_position = frog.global_position

func update(delta: float) -> void:
	if not frog or frog.is_stunned:
		return
		
	_timer += delta
	if _timer >= hide_duration:
		print("[HideState] Hide duration ended. Revealing and returning to Idle.")
		frog.set_hidden(false)
		parent_state_machine.change_state("FrogIdleState")

func exit() -> void:
	if frog and frog.is_hidden:
		frog.set_hidden(false)
