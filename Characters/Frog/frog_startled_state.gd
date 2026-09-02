class_name FrogStartledState
extends State

@export var frog: FrogMob

func enter() -> void:
	#print("[StartledState] ENTERED. Frog is startled, revealed, and reacting!")
	if not frog:
		return
		
	frog.velocity = Vector3.ZERO
	
	# 1. Flash visible when startled by the player
	frog.set_hidden(false)
	
	# 2. Play the startled/attack animation and wait for it to complete
	if frog.animation_player:
		var anim_name = "Armature|Frog_Attack" # Or your alert animation name
		if frog.animation_player.has_animation(anim_name):
			frog.animation_player.play(anim_name)
			await frog.animation_player.animation_finished
		else:
			await get_tree().create_timer(1.0).timeout
			
	# 3. SAFETY CHECK: If the frog got stunned during its animation, abort fleeing!
	if not frog or frog.is_stunned:
		#print("[StartledState] Aborted flee because frog was stunned.")
		return
		
	# 4. Otherwise, disappear back into shadows and flee
	#print("[StartledState] Reaction complete. Re-hiding and fleeing!")
	frog.set_hidden(true)
	
	if parent_state_machine:
		parent_state_machine.change_state("FrogRunFromPlayerState")

func update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
