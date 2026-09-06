extends Node3D

@export var cpu_particles_3d: CPUParticles3D
@export var audio_stream_player_3d: AudioStreamPlayer3D

func _ready() -> void:
	_play_effect()

func _play_effect() -> void:
	var particle_duration: float = 0.0
	var audio_duration: float = 0.0

	# Calculate particle lifespan and trigger emission
	if cpu_particles_3d:
		cpu_particles_3d.emitting = true
		particle_duration = cpu_particles_3d.lifetime + (cpu_particles_3d.explosiveness * cpu_particles_3d.lifetime)

	# Calculate audio lifespan and play sound
	if audio_stream_player_3d and audio_stream_player_3d.stream:
		audio_stream_player_3d.play()
		audio_duration = audio_stream_player_3d.stream.get_length()

	# Wait for whichever effect takes longer
	var max_duration: float = max(particle_duration, audio_duration)
	
	if max_duration > 0.0:
		await get_tree().create_timer(max_duration).timeout

	queue_free()
