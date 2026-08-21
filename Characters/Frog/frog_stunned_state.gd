class_name FrogStunnedState
extends State

@export var frog: FrogMob
@export var stun_duration: float = 3.0

var _timer: float = 0.0

func enter() -> void:
	print("[StunnedState] ENTERED. Frog is stunned and vulnerable.")
	_timer = 0.0
	
	if frog:
		frog.velocity = Vector3.ZERO
		frog.is_stunned = true
		frog.set_hidden(false)
		
		# Play death/stun animation forward
		if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
			frog.animation_player.play("Armature|Frog_Death")

func update(delta: float) -> void:
	if not frog:
		return
		
	# If it's picked up during this window, collection logic handles it, so do nothing here
	if frog.is_picked_up:
		return
		
	_timer += delta
	if _timer >= stun_duration:
		print("[StunnedState] Stun expired. Recovering and fleeing back to cover!")
		
		# Play the death animation in reverse to "un-stun" / revive
		if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
			# Play backwards from the end of the animation
			frog.animation_player.play_backwards("Armature|Frog_Death")
			await frog.animation_player.animation_finished
			
		# Reset stun flag so it can behave normally again
		frog.is_stunned = false
		
		# Transition back to running away or hiding
		if parent_state_machine:
			parent_state_machine.change_state("FrogHideState")

func exit() -> void:
	if frog:
		# Safety fallback in case it exits via collection
		frog.is_stunned = false
