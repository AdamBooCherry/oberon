## MAIN.GD ##
extends Node3D
class_name Main

@export_group("References")
@export var player: Player
@export var player_spawn: PlayerSpawn

func _ready() -> void:
	if GameManager:
		GameManager.return_to_start.connect(_on_return_to_start)
		GameManager.begin_round_lose.connect(_on_begin_round_lose)
		GameManager.begin_round_win.connect(_on_begin_round_win)
	_start_round()

func _on_return_to_start() -> void:
	_start_round()

func _on_begin_round_lose() -> void:
	GameManager.oberon_score += 1
	GameManager.emit_round_reset_started()
	
	# Increment Oberon's score on player death
	
	await get_tree().create_timer(1.5).timeout

	GameManager.day_number += 1
	_start_round()
	
	GameManager.emit_round_reset_finished()
	_check_game_over()

func _on_begin_round_win() -> void:
	GameManager.player_score += 1
	GameManager.emit_round_reset_started()
	
	await get_tree().create_timer(1.5).timeout

	GameManager.day_number += 1
	_start_round()
	
	GameManager.emit_round_reset_finished()
	_check_game_over()

func _start_round() -> void:
	InventoryManager.reset_inventory()
	EnvironmentManager.change_state(EnvironmentManager.EnvironmentState.SAFE)
	
	if player and player_spawn:
		player.velocity = Vector3.ZERO
		player.global_transform = player_spawn.global_transform
		player.begin_day()

func _check_game_over() -> bool:
	if GameManager.player_score >= 3:
		_trigger_ending()
		return true
	elif GameManager.oberon_score >= 3:
		_trigger_ending()
		return true
	return false

func _trigger_ending() -> void:
	print("The festival is over! Time for the big finish!")
	# Add your Dialogic timeline start or cutscene trigger here
	pass
