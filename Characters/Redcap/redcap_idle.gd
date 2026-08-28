## REDCAP IDLE ##
extends State

@export var redcap: Redcap
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 4.0

var _timer: float = 0.0
var _target_time: float = 2.0

func enter() -> void:
	GameManager.emit_change_to_default_environment()

	if redcap and redcap.animation_player:
		var anim_name = "drunk_idle_01"
		
		# Option 1: Standard global library check
		if redcap.animation_player.has_animation(anim_name):
			redcap.animation_player.play(anim_name)
		# Option 2: Godot slash-delimited library check
		elif redcap.animation_player.has_animation("redcap_animations/" + anim_name):
			redcap.animation_player.play("redcap_animations/" + anim_name)
		else:
			print("[Redcap Idle] Animation not found! Available animations: ", redcap.animation_player.get_animation_list())

	_timer = 0.0
	_target_time = randf_range(min_idle_time, max_idle_time)
	
	if redcap:
		redcap.velocity = Vector3.ZERO

func update(delta: float) -> void:
	if not redcap:
		return
		
	# Quick property safeguard if redcap lacks an is_stunned flag
	if "is_stunned" in redcap and redcap.is_stunned:
		return

	_timer += delta

	if _timer >= _target_time:
		# Matches your Redcap export variable node or your state machine string keys
		parent_state_machine.change_state("SEARCHING")
