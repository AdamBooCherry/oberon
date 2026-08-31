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
		
	# Track when both are done
	var particle_finished = false
	var audio_finished = false
	
	# Listen for audio completion
	if audio_stream_player_3d:
		audio_stream_player_3d.finished.connect(func():
			audio_finished = true
			_check_cleanup(particle_finished, audio_finished)
		)
	else:
		audio_finished = true # If no audio, mark as done immediately

	# Listen for particles completion using a timer matching lifetime
	if cpu_particles_3d:
		var lifetime = cpu_particles_3d.lifetime + cpu_particles_3d.explosiveness * cpu_particles_3d.lifetime
		get_tree().create_timer(lifetime).timeout.connect(func():
			particle_finished = true
			_check_cleanup(particle_finished, audio_finished)
		)
	else:
		particle_finished = true

func _check_cleanup(particles_done: bool, audio_done: bool) -> void:
	if particles_done and audio_done:
		queue_free()
