extends Node

func _ready() -> void:
	# Engine.is_editor_hint() returns true if you are looking at it in the editor,
	# and false if the game is running (even if you are running the scene directly).
	if not Engine.is_editor_hint():
		queue_free()
