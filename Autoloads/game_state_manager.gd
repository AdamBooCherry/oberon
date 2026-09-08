### GAME STATE MANAGER ###
extends Node

signal state_changed(new_state: GameState, previous_state: GameState)
signal gameplay_locked
signal gameplay_unlocked

enum GameState {
	PLAYING,
	CUTSCENE,
	DIALOGUE,
	PAUSED,
	ROUND_TRANSITION
}

var current_state: GameState = GameState.PLAYING:
	set = _set_state

var is_locked: bool:
	get: return current_state != GameState.PLAYING

func _ready() -> void:
	# Hook into CutsceneManager lifecycle
	if CutsceneManager:
		CutsceneManager.started.connect(func(_res): set_state(GameState.CUTSCENE))
		CutsceneManager.ended.connect(func(_res): _restore_default_state())

	# Hook into Dialogic timeline lifecycle
	if Dialogic:
		Dialogic.timeline_started.connect(func(): set_state(GameState.DIALOGUE))
		Dialogic.timeline_ended.connect(func(): _restore_default_state())

func set_state(new_state: GameState) -> void:
	current_state = new_state

func _set_state(value: GameState) -> void:
	if current_state == value:
		return

	var previous = current_state
	var was_locked = is_locked
	current_state = value

	state_changed.emit(current_state, previous)

	if is_locked and not was_locked:
		gameplay_locked.emit()
	elif not is_locked and was_locked:
		gameplay_unlocked.emit()

func _restore_default_state() -> void:
	# Prevent unlocking gameplay if ending dialogue inside an active cutscene
	if CutsceneManager and CutsceneManager.is_active:
		set_state(GameState.CUTSCENE)
	elif Dialogic and Dialogic.current_timeline != null:
		set_state(GameState.DIALOGUE)
	else:
		set_state(GameState.PLAYING)
