class_name FrogStunnedState
extends State

@export var frog: FrogMob

func enter() -> void:
	print("[StunnedState] ENTERED. Frog is stunned.")
	if frog:
		frog.velocity = Vector3.ZERO
		frog.is_stunned = true
		
		if frog.animation_player:
			frog.animation_player.play("Armature|Frog_Death") # Or your stun loop animation

func update(_delta: float) -> void:
	# While stunned, the frog doesn't move or change states on its own.
	# It waits for FrogMob's pickup logic (get_picked_up) to queue_free it.
	pass
