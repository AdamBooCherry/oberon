## REDCAP IDLE ##
extends State

@export var redcap: Redcap
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 4.0

var _timer: float = 0.0
var _target_time: float = 2.0

func enter() -> void:
	print("[RedcapIdle] ENTER state.")
	EnvironmentManager.change_state(EnvironmentManager.EnvironmentState.SAFE)

	if redcap and redcap.animation_player:
		redcap.animation_player.play("redcap_animations/drunk_idle_01")

	_timer = 0.0
	_target_time = randf_range(min_idle_time, max_idle_time)
	#print("[RedcapIdle] Target idle duration set to: ", _target_time, " seconds.")

	redcap.velocity = Vector3.ZERO
