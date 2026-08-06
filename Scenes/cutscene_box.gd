extends Node3D
class_name CutsceneBox

@export var camera_3d: Camera3D

func start_cutscene():
	camera_3d.make_current()
	pass

func end_cutscene():
	pass
