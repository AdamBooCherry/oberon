class_name FrogIdleState
extends State

@export var frog: FrogMob
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 4.0

var _timer: float = 0.0
var _target_time: float = 2.0

func enter() -> void:
	#print("[IdleState] ENTERED. Waiting for idle timer...")
	#GameManager.emit_change_to_default_environment()

	if frog and frog.animation_player:
		frog.animation_player.play("Armature|Frog_Idle")
		## right here doesn't seem to be registering correctly
		
	_timer = 0.0
	_target_time = randf_range(min_idle_time, max_idle_time)
	#print("[IdleState] Target idle time set to: ", _target_time)
	
	if frog:
		frog.velocity = Vector3.ZERO

func update(delta: float) -> void:
	if not frog:
		return
		
	if frog.is_stunned:
		return

	_timer += delta
	
	# Print every second or so to confirm it's counting up
	# (Using int check to avoid spamming the console every single frame)
	#if int(_timer) != int(_timer - delta):
		#print("[IdleState] Idle timer: ", snappedf(_timer, 0.1), " / ", _target_time)

	# Once idle time is up, transition to wandering
	if _timer >= _target_time:
		#print("[IdleState] Time's up! Switching to FrogWanderState.")
		parent_state_machine.change_state("FrogWanderState")
