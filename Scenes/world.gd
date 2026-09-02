class_name World
extends Node3D

@export_group("References")
@export var world_environment: WorldEnvironment
@export var world_transition: AudioStreamPlayer

@export_group("Particle Systems")
@export var safe_particles: GPUParticles3D
@export var investigating_particles: GPUParticles3D
@export var chase_particles: GPUParticles3D
@export var death_particles: GPUParticles3D

@export_group("Environment Resources")
@export var safe_environment: Environment
@export var investigating_environment: Environment
@export var chase_environment: Environment
@export var death_environment: Environment

var current_environment: Environment

func _ready() -> void:
	EnvironmentManager.environment_changed.connect(_on_environment_changed)
	_apply_world_state(EnvironmentManager.current_state)

func _on_environment_changed(new_state: EnvironmentManager.EnvironmentState, _old_state: EnvironmentManager.EnvironmentState) -> void:
	_apply_world_state(new_state)

func _apply_world_state(state: EnvironmentManager.EnvironmentState) -> void:
	var target_env: Environment = _get_environment_resource(state)
	
	if target_env and current_environment != target_env:
		current_environment = target_env
		
		if is_instance_valid(world_environment):
			world_environment.environment = target_env
			
		if is_instance_valid(world_transition):
			world_transition.play()

	_update_world_effects(state)

func _get_environment_resource(state: EnvironmentManager.EnvironmentState) -> Environment:
	match state:
		EnvironmentManager.EnvironmentState.SAFE:
			return safe_environment
		EnvironmentManager.EnvironmentState.INVESTIGATING:
			return investigating_environment
		EnvironmentManager.EnvironmentState.CHASE:
			return chase_environment
		EnvironmentManager.EnvironmentState.DEATH:
			return death_environment
		_:
			return null

func _update_world_effects(state: EnvironmentManager.EnvironmentState) -> void:
	if is_instance_valid(safe_particles):
		safe_particles.emitting = (state == EnvironmentManager.EnvironmentState.SAFE)

	if is_instance_valid(investigating_particles):
		investigating_particles.emitting = (state == EnvironmentManager.EnvironmentState.INVESTIGATING)

	if is_instance_valid(chase_particles):
		chase_particles.emitting = (state == EnvironmentManager.EnvironmentState.CHASE)
		
	if is_instance_valid(death_particles):
		death_particles.emitting = (state == EnvironmentManager.EnvironmentState.DEATH)
