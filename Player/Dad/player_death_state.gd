extends State
class_name DeathState

@export var player_dad: Player

func enter() -> void:
	player_dad.velocity = Vector3.ZERO

	# Disable hurtbox immediately to cut incoming damage
	if player_dad.hurtbox:
		#print("STATE: DeathState -> Disabling hurtbox...")
		player_dad.hurtbox.set_deferred("monitoring", false)
		player_dad.hurtbox.set_deferred("monitorable", false)

	if player_dad.animation_player:
		#print("STATE: DeathState -> Playing dying animation...")
		player_dad.animation_player.play("Dad/dying")
		await player_dad.animation_player.animation_finished
		player_dad.animation_player.pause()

	GameManager.emit_begin_death_sequence()

#func exit() -> void:
	## Unpause animation player so future states can play animations smoothly
	#print("STATE: DeathState -> exit()")
	#if player_dad.animation_player:
		#player_dad.animation_player.play()
