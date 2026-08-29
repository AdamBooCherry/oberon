### GAME MANAGER ###
extends Node

signal change_to_default_environment
signal change_to_scary_environment
signal begin_death_sequence
signal return_to_start
signal round_reset_started
signal round_reset_finished

func emit_change_to_default_environment():
	change_to_default_environment.emit()

func emit_change_to_scary_environment():
	change_to_scary_environment.emit()

func emit_begin_death_sequence():
	begin_death_sequence.emit()

func emit_return_to_start():
	return_to_start.emit()

func emit_round_reset_started():
	round_reset_started.emit()

func emit_round_reset_finished():
	round_reset_finished.emit()
