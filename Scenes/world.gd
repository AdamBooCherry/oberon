class_name World
extends Node3D

@export_group("References")
@export var world_environment: WorldEnvironment
@export var default_environment: Environment
@export var scary_environment: Environment
@export var world_transition: AudioStreamPlayer

var current_environment: Environment

func _ready() -> void:
	print("[World] Ready. Connecting GameManager signals...")
	GameManager.change_to_default_environment.connect(func(): _change_environment(default_environment))
	GameManager.change_to_scary_environment.connect(func(): _change_environment(scary_environment))
	
	current_environment = default_environment
	if world_environment and default_environment:
		world_environment.environment = default_environment
		print("[World] Initialized with default environment.")
	else:
		print("[World] WARNING: world_environment or default_environment is missing in inspector!")

func _change_environment(new_env: Environment) -> void:
	print("[World] _change_environment called. Requested new_env: ", new_env)
	
	if not new_env:
		print("[World] ABORT: new_env is null!")
		return
		
	if current_environment == new_env:
		print("[World] ABORT: new_env is already the current environment. Skipping.")
		return
		
	current_environment = new_env
	
	if world_environment:
		world_environment.environment = new_env
		print("[World] Success: Environment changed visually.")
	else:
		print("[World] ERROR: world_environment reference is null!")
		
	if world_transition:
		world_transition.play()
		print("[World] Playing transition audio.")
	else:
		print("[World] NOTE: world_transition audio player is not assigned.")
