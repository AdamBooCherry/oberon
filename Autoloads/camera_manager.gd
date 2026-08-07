### CAMERA MANAGER AUTOLOAD ###
extends Node

signal change_to_debug_camera
signal cutscene_started(cutscene_id: StringName)
signal cutscene_ended(cutscene_id: StringName)

var off_camera_timer: float = 5.0
var active_cutscene_camera: Camera3D = null
var previous_camera: Camera3D = null

@onready var _timer: Timer = Timer.new()

func _ready() -> void:
	add_child(_timer)
	_timer.one_shot = true
	_timer.timeout.connect(_on_off_camera_timeout)

func start_off_camera_timer() -> void:
	_timer.start(off_camera_timer)

func stop_off_camera_timer() -> void:
	_timer.stop()

func _on_off_camera_timeout() -> void:
	change_to_debug_camera.emit()

func play_cutscene_camera(target_camera: Camera3D, cutscene_id: StringName) -> void:
	if not target_camera:
		return
		
	# Save whatever camera was active before so we can return to it later
	previous_camera = get_viewport().get_camera_3d()
	active_cutscene_camera = target_camera
	
	# Switch to the cutscene camera
	target_camera.make_current()
	
	# Notify the game (Player can disable input, UI can fade out, etc.)
	cutscene_started.emit(cutscene_id)

func end_cutscene_camera(cutscene_id: StringName) -> void:
	# Return to the previous camera if it still exists
	if is_instance_valid(previous_camera):
		previous_camera.make_current()
	
	active_cutscene_camera = null
	cutscene_ended.emit(cutscene_id)
