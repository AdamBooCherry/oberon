extends State

#func enter() -> void:
	## Clean up any active hitboxes, particle effects, or action animations
	#if player.hook:
		#player.hook.disable_hitbox()

# Intentionally leave update() and physics_update() completely empty.
# Any action inputs (swing, interact, toggle torch) received while here are ignored.
