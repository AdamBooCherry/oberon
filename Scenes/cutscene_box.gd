@icon("uid://xiogdm1g0g02")
extends Node3D
class_name CutsceneBox

signal cutscene_started
signal cutscene_finished
signal cutscene_skipped

@export var cutscene_id: StringName = &""
@export var resource: CutsceneResource
@export var cutscene_player: AnimationPlayer
@export var cutscene_cam: Camera3D

func _ready() -> void:
	if cutscene_id != &"" and CutsceneManager:
		CutsceneManager.register_cutscene(cutscene_id, self)

func _exit_tree() -> void:
	if cutscene_id != &"" and CutsceneManager:
		CutsceneManager.unregister_cutscene(cutscene_id)

func start_cutscene() -> void:
	if CutsceneManager.current_resource != null:
		return

	if cutscene_cam:
		cutscene_cam.make_current()

	cutscene_started.emit()
	CutsceneManager.play(resource, cutscene_player, _on_skip)
	
	await CutsceneManager.ended
	_finish()

func _on_skip() -> void:
	# Snap animation to end frame if animation exists
	if cutscene_player and resource and cutscene_player.has_animation(resource.animation_name):
		var anim = cutscene_player.get_animation(resource.animation_name)
		cutscene_player.seek(anim.length, true)
	
	cutscene_skipped.emit()

func _finish() -> void:
	cutscene_finished.emit()
