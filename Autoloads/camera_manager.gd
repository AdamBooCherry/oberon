### CAMERA MANAGER AUTOLOAD ###
extends Node

signal change_to_debug_camera

var off_camera_timer: float = 5.0
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
