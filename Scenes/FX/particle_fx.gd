extends Node3D

@export var cpu_particles_3d: CPUParticles3D
@export var audio_stream_player_3d: AudioStreamPlayer3D

func _ready() -> void:
	_play_effect()

func _play_effect() -> void:
	if cpu_particles_3d:
		cpu_particles_3d.emitting = true
		
	if audio_stream_player_3d:
		audio_stream_player_3d.play()

	# Run both completion checks concurrently
	await _wait_for_completion()
	queue_free()

func _wait_for_completion() -> void:
	# Create async tasks for both particles and audio
	var tasks: Array[Signal] = []

	if cpu_particles_3d:
		var lifetime: float = cpu_particles_3d.lifetime + (cpu_particles_3d.explosiveness * cpu_particles_3d.lifetime)
		var particle_timer := get_tree().create_timer(lifetime)
		tasks.append(particle_timer.timeout)

	if audio_stream_player_3d and audio_stream_player_3d.stream:
		tasks.append(audio_stream_player_3d.finished)

	# Await each active completion signal in parallel
	for task_signal in tasks:
		await task_signal
