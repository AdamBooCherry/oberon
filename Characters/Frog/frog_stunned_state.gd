class_name FrogStunnedState
extends State

@export var frog: FrogMob
@export var stun_duration: float = 3.0

var _timer: float = 0.0
var _is_recovering: bool = false

func enter() -> void:
	#print("[StunnedState] ENTERED. Frog is stunned and vulnerable.")
	_timer = 0.0
	_is_recovering = false
	GameManager.emit_change_to_default_environment()

	
	if frog:
		frog.velocity = Vector3.ZERO
		frog.is_stunned = true
		frog.set_hidden(false)
		
		if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
			frog.animation_player.play("Armature|Frog_Death")

func update(delta: float) -> void:
	if not frog or _is_recovering:
		return
		
	if frog.is_picked_up:
		return
		
	_timer += delta
	if _timer >= stun_duration:
		_is_recovering = true # Lock out further timer checks while recovering
		_recover_and_escape()

func _recover_and_escape() -> void:
	#print("[StunnedState] Stun expired. Recovering and fleeing back to cover!")
	
	if frog and frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
		frog.animation_player.play_backwards("Armature|Frog_Death")
		await frog.animation_player.animation_finished
		
	if not frog:
		return
		
	frog.is_stunned = false
	
	if parent_state_machine:
		parent_state_machine.change_state("FrogHideState")

func exit() -> void:
	if frog:
		frog.is_stunned = false
