class_name World
extends Node3D

@export_group("References")
@export var world_environment: WorldEnvironment
@export var default_environment: Environment
@export var scary_environment: Environment
@export var world_transition: AudioStreamPlayer

var current_environment: Environment

func _ready() -> void:
	GameManager.change_to_default_environment.connect(func(): _change_environment(default_environment))
	GameManager.change_to_scary_environment.connect(func(): _change_environment(scary_environment))
	current_environment = default_environment

func _change_environment(new_env: Environment) -> void:
	if not new_env or current_environment == new_env:
		return
		
	current_environment = new_env
	
	if world_environment:
		world_environment.environment = new_env
		
	if world_transition:
		world_transition.play()
