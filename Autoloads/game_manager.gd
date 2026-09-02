### GAME MANAGER ###
extends Node

signal begin_round_lose
signal begin_round_win
signal return_to_start
signal round_reset_started
signal round_reset_finished
signal player_score_changed(score: int)
signal oberon_score_changed(score: int)
signal day_number_changed(value: int)

var day_number: int = 1:
	set(value):
		day_number = value
		day_number_changed.emit(day_number)

var player_score: int = 0:
	set(value):
		player_score = value
		player_score_changed.emit(player_score)

var oberon_score: int = 0:
	set(value):
		oberon_score = value
		oberon_score_changed.emit(oberon_score)

func emit_begin_round_lose():
	begin_round_lose.emit()

func emit_begin_round_win():
	begin_round_win.emit()

func emit_return_to_start():
	return_to_start.emit()

func emit_round_reset_started():
	round_reset_started.emit()

func emit_round_reset_finished():
	round_reset_finished.emit()
