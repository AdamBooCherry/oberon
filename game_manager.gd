### GAME MANAGER ###
extends Node

signal change_to_default_environment
signal change_to_scary_environment

func emit_change_to_default_environment():
	change_to_default_environment.emit()

func emit_change_to_scary_environment():
	change_to_scary_environment.emit()
