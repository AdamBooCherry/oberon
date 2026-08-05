extends Area3D
class_name CameraActivator

@export var notifier: VisibleOnScreenNotifier3D

var areas_currently_in: Array[CameraTriggerArea] = []
var is_on_screen: bool = true

func _ready() -> void:
	# Area3D signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Connect to notifier signals if assigned
	if notifier:
		notifier.screen_entered.connect(_on_screen_entered)
		notifier.screen_exited.connect(_on_screen_exited)
	else:
		push_warning("CameraActivator: No VisibleOnScreenNotifier3D assigned!")

# --- Area Callbacks ---

func _on_area_entered(area: Area3D) -> void:
	if area is CameraTriggerArea and not areas_currently_in.has(area):
		areas_currently_in.append(area)
		_evaluate_camera_state()

func _on_area_exited(area: Area3D) -> void:
	if area is CameraTriggerArea:
		areas_currently_in.erase(area) # Corrected Godot 4 syntax
		_evaluate_camera_state()

# --- Notifier Callbacks ---

func _on_screen_entered() -> void:
	is_on_screen = true
	_evaluate_camera_state()

func _on_screen_exited() -> void:
	is_on_screen = false
	_evaluate_camera_state()

# --- Logic Evaluation ---

func _evaluate_camera_state() -> void:
	var is_in_trigger: bool = not areas_currently_in.is_empty()
	
	# Start timer if OFF screen AND NOT in any trigger area
	if not is_on_screen and not is_in_trigger:
		CameraManager.start_off_camera_timer()
	else:
		CameraManager.stop_off_camera_timer()
