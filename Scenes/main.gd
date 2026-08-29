## MAIN.GD ##
extends Node3D

@export_group("References")
@export var player: Player
@export var player_spawn: PlayerSpawn

func _ready() -> void:
	print("[Main] _ready() initialized.")
	if GameManager:
		GameManager.return_to_start.connect(_on_return_to_start)
		GameManager.begin_death_sequence.connect(_on_begin_death_sequence)
	
	# Initial game start
	_start_round()

func _on_return_to_start() -> void:
	print("[Main] Received signal: return_to_start")
	_start_round()

func _on_begin_death_sequence() -> void:
	print("--- MAIN: _on_begin_death_sequence STARTED ---")
	GameManager.emit_round_reset_started()
	
	#print("MAIN: Starting 1-second transition delay...")
	#await get_tree().create_timer(1.0).timeout
	#
	#print("MAIN: Delay finished. Calling _start_round()...")
	_start_round()
	
	GameManager.emit_round_reset_finished()
	print("--- MAIN: _on_begin_death_sequence FINISHED ---")

func _start_round() -> void:
	print("MAIN: _start_round() called. Repositioning player to spawn...")
	if player and player_spawn:
		player.velocity = Vector3.ZERO
		player.global_transform = player_spawn.global_transform
		
	if player:
		player.begin_day()
