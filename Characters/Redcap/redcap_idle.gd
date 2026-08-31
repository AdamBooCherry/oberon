## REDCAP IDLE ##
extends State

@export var redcap: Redcap
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 4.0

var _timer: float = 0.0
var _target_time: float = 2.0

func enter() -> void:
	print("[RedcapIdle] ENTER state.")
	GameManager.emit_change_to_default_environment()

	if redcap and redcap.animation_player:
		redcap.animation_player.play("redcap_animations/drunk_idle_01")
	else:
		push_warning("[RedcapIdle] Redcap or AnimationPlayer reference missing!")

	_timer = 0.0
	_target_time = randf_range(min_idle_time, max_idle_time)
	print("[RedcapIdle] Target idle duration set to: ", _target_time, " seconds.")

	if redcap:
		redcap.velocity = Vector3.ZERO
	else:
		push_warning("[RedcapIdle] Redcap export variable is NULL!")

# Added process fallback in case state machine calls process_update/physics_update
func update(delta: float) -> void:
	_tick_idle(delta, "update")

func physics_update(delta: float) -> void:
	_tick_idle(delta, "physics_update")

func process_update(delta: float) -> void:
	_tick_idle(delta, "process_update")

func _tick_idle(delta: float, source_method: String) -> void:
	if not redcap:
		print("[RedcapIdle] Stuck: 'redcap' reference is null!")
		return

	if "is_stunned" in redcap and redcap.is_stunned:
		print("[RedcapIdle] Stuck: redcap.is_stunned is TRUE.")
		return

	_timer += delta

	# Log timer progress periodically
	if Engine.get_process_frames() % 60 == 0:
		print("[RedcapIdle] Active via '", source_method, "' | Progress: ", snappedf(_timer, 0.1), " / ", snappedf(_target_time, 0.1))

	if _timer >= _target_time:
		print("[RedcapIdle] Timer completed! Requesting state change to 'WANDERING'.")

		if parent_state_machine:
			# Verify whether transition method exists
			if parent_state_machine.has_method("change_state"):
				parent_state_machine.change_state("WANDERING")
			elif parent_state_machine.has_method("transition_to"):
				parent_state_machine.transition_to("WANDERING")
			else:
				push_error("[RedcapIdle] Parent state machine lacks change_state or transition_to methods!")
		else:
			push_error("[RedcapIdle] parent_state_machine reference is NULL!")

func exit() -> void:
	print("[RedcapIdle] EXIT state.")
