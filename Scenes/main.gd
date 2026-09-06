extends Node3D
class_name Main

## Controls round life cycles, spawn placement, and scene-level audio triggers.

@export_group("References")
@export var player: Player
@export var player_spawn: PlayerSpawn

@export_group("Audio Streams")
@export var gameplay_music: AudioStream
@export var gameplay_ambience: AudioStream
@export var win_sting: AudioStream
@export var lose_sting: AudioStream

# ==============================================================================
# LIFECYCLE & SIGNALS
# ==============================================================================

func _ready() -> void:
	if GameManager:
		GameManager.return_to_start.connect(_on_return_to_start)
		GameManager.begin_round_lose.connect(_on_begin_round_lose)
		GameManager.begin_round_win.connect(_on_begin_round_win)
		GameManager.start_round.connect(_start_round)
		
	_reset_round()


func _on_return_to_start() -> void:
	_reset_round()


func _on_begin_round_lose() -> void:
	GameManager.oberon_score += 1
	_play_round_end_sting(lose_sting)
	_advance_round()


func _on_begin_round_win() -> void:
	GameManager.player_score += 1
	_play_round_end_sting(win_sting)
	_advance_round()


# ==============================================================================
# ROUND MANAGEMENT
# ==============================================================================

func _start_round() -> void:
	if gameplay_music:
		MusicManager.play_music(gameplay_music, 1.5)


func _reset_round() -> void:
	InventoryManager.reset_inventory()
	EnvironmentManager.change_state(EnvironmentManager.EnvironmentState.SAFE)
	
	if gameplay_ambience:
		MusicManager.play_ambience(gameplay_ambience, 1.0)
	
	if player and player_spawn:
		player.velocity = Vector3.ZERO
		player.global_transform = player_spawn.global_transform
		player.begin_day()


func _advance_round() -> void:
	GameManager.emit_round_reset_started()
	
	await get_tree().create_timer(1.5).timeout

	GameManager.day_number += 1
	
	if not _check_game_over():
		_reset_round()
	
	GameManager.emit_round_reset_finished()


func _check_game_over() -> bool:
	if GameManager.player_score >= 3 or GameManager.oberon_score >= 3:
		_trigger_ending()
		return true
	return false


func _trigger_ending() -> void:
	print("The festival is over! Time for the big finish!")
	MusicManager.stop_music(2.0)
	MusicManager.stop_ambience(2.0)


# ==============================================================================
# AUDIO HELPERS
# ==============================================================================

func _play_round_end_sting(sting: AudioStream) -> void:
	MusicManager.stop_music(0.5)
	if sting:
		MusicManager.play_music(sting, 0.0)
