extends State
class_name DeathState

@export var player_dad: Player

func enter() -> void:
	# Zero horizontal movement immediately on death
	player_dad.velocity.x = 0.0
	player_dad.velocity.z = 0.0

	if player_dad.animation_player:
		# Connect signal to pause or lock state when finished
		if not player_dad.animation_player.animation_finished.is_connected(_on_animation_finished):
			player_dad.animation_player.animation_finished.connect(_on_animation_finished)
		
		player_dad.animation_player.play("Dad/dying")

	# Disable hurtbox if present to prevent further damage signals
	if player_dad.hurtbox:
		player_dad.hurtbox.set_deferred("monitoring", false)
		player_dad.hurtbox.set_deferred("monitorable", false)

func physics_update(delta: float) -> void:
	# Apply gravity so player lands on ground if dying mid-air
	if not player_dad.is_on_floor():
		player_dad.velocity.y -= player_dad.gravity * delta
	else:
		player_dad.velocity.x = 0.0
		player_dad.velocity.z = 0.0

func _on_animation_finished(anim_name: StringName) -> void:
	player_dad.animation_player.pause()
	GameManager.emit_begin_death_sequence()
